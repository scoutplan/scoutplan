# rubocop:disable Metrics/ClassLength
class Event < ApplicationRecord
  include Notifiable, Remindable, Onlineable, Icalendarable, Replyable, DatePresentable, StaticMappable
  extend DateTimeAttributes

  date_time_attrs_for :starts_at, :ends_at

  attr_accessor :repeats, :notify_members, :notify_recipients, :notify_message, :document_library_ids

  default_scope { where(parent_event_id: nil).order(starts_at: :asc) }

  belongs_to :unit
  belongs_to :series_parent, class_name: "Event", optional: true
  belongs_to :parent_event, class_name: "Event", optional: true
  belongs_to :event_category

  has_many :documents, as: :documentable, dependent: :destroy
  has_many :document_types, as: :document_typeable, dependent: :destroy
  has_many :event_activities, dependent: :destroy
  has_many :event_locations, inverse_of: :event, dependent: :destroy
  has_many :event_organizers, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :event_shifts, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy
  has_many :locations, through: :event_locations
  has_many :payments, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :members, through: :event_rsvps
  has_many :rsvp_tokens, dependent: :destroy
  has_many :sub_events, class_name: "Event", foreign_key: "parent_event_id"
  has_many :unit_memberships, through: :event_rsvps

  has_one :chat, as: :chattable, dependent: :destroy

  has_rich_text :description

  has_one_attached :static_map
  has_many_attached :attachments
  has_many_attached :private_attachments

  has_paper_trail versions: { scope: -> { order("id desc") } }

  has_secure_token

  accepts_nested_attributes_for :event_locations, allow_destroy: true
  accepts_nested_attributes_for :event_organizers, allow_destroy: true

  alias_method :rsvps, :event_rsvps
  alias_method :category, :event_category
  alias_method :activities, :event_activities
  alias_method :organizers, :event_organizers
  alias_method :shifts, :event_shifts

  validates_presence_of :title, :starts_at, :ends_at
  validate :dates_are_subsequent
  validates :attachments,
            content_type: [
              "image/png", "image/jpg", "image/jpeg", "image/gif", "application/pdf", "text/plain",
              "application/msword",
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
              "application/vnd.ms-excel",
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              "application/vnd.ms-powerpoint",
              "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            ],
            size:         {
              less_than: 10.megabytes, message: "must be less than 5 MB"
            }

  enum status: { draft: 0, published: 1, cancelled: 2, archived: 3 }

  # TODO: clean up this mess
  scope :past,          -> { where("starts_at < ?", Date.today.in_time_zone) }
  scope :future,        -> { where("ends_at > ?", Date.today.in_time_zone) }
  scope :recent,        -> { where("starts_at BETWEEN ? AND ?", 4.weeks.ago, Date.today) }
  scope :this_week,     lambda {
                          where("starts_at BETWEEN ? AND ?", Time.current, 6.days.from_now.at_end_of_day.in_time_zone)
                        }
  scope :upcoming,      -> { where("starts_at BETWEEN ? AND ?", Time.current, 35.days.from_now) }
  scope :coming_up,     -> { where("starts_at BETWEEN ? AND ?", 7.days.from_now, 35.days.from_now) }
  scope :further_out,   -> { where("starts_at > ?", 35.days.from_now) }
  scope :rsvp_required, -> { where(requires_rsvp: true) }
  scope :today,         lambda {
                          where("starts_at BETWEEN ? AND ?", Time.zone.now.beginning_of_day, Time.zone.now.at_end_of_day)
                        }
  scope :imminent, lambda {
    where("starts_at BETWEEN ? AND ?",
          Time.zone.now.hour < 12 ? Time.zone.now.middle_of_day : Time.zone.now.end_of_day,
          Time.zone.now.hour < 12 ? Time.zone.now.end_of_day : Time.zone.now.end_of_day + 12.hours)
  }

  scope :recent_and_future, -> { where("starts_at > ?", 4.weeks.ago) }
  scope :recent_and_upcoming, -> { where("starts_at BETWEEN ? AND ?", 4.weeks.ago, 35.days.from_now) }
  scope :this_season, -> { where("starts_at BETWEEN ? AND ?", this_season_starts_at, this_season_ends_at) }
  scope :next_season, -> { where("starts_at BETWEEN ? AND ?", next_season_starts_at, next_season_ends_at) }
  scope :intending_to_go, -> { where("response IN ['accepted', 'accepted_pending']") }
  scope :rsvp_expiring_soon, -> { where("rsvp_closes_at BETWEEN ? AND ?", Time.current, Date.tomorrow.at_end_of_day) }

  acts_as_taggable_on :tags
  acts_as_taggable_tenant :unit_id

  delegate :next_season_starts_at, :next_season_ends_at, to: :unit

  auto_strip_attributes :website

  def category_name
    event_category.name
  end

  def this_season_starts_at
    unit.this_season_starts_at
  end

  # rubocop:disable Metrics/AbcSize
  def dates_are_subsequent
    errors.add(:ends_at, "must be after start_date") if starts_at > ends_at
    return unless requires_rsvp?

    errors.add(:rsvp_closes_at, "must be before start_date") if rsvp_closes_at > starts_at
    return unless rsvp_opens_at.present?

    errors.add(:rsvp_opens_at, "must be before start_date") if rsvp_opens_at > starts_at
    errors.add(:rsvp_opens_at, "must be before rsvp_closes_at") if rsvp_opens_at > rsvp_closes_at
  end
  # rubocop:enable Metrics/AbcSize

  def full_title
    "#{unit.name} #{title}"
  end

  def organizable?
    requires_rsvp
  end

  def started?
    starts_at.past?
  end

  def ended?
    ends_at.past?
  end

  def past?
    ended?
  end

  def requires_payment?
    (cost_adult + cost_youth).positive?
  end

  def requirements?
    requires_rsvp? || requires_payment? || documents_required?
  end

  ### RSVP-related methods
  def headcount_limit_reached?
    return false unless limits_headcount?

    rsvps.accepted.count >= max_total_attendees
  end

  def headcount_remaining
    return 0 unless limits_headcount?

    max_total_attendees - rsvps.accepted.count
  end

  # override getter
  def rsvp_closes_at
    read_attribute(:rsvp_closes_at)&.at_end_of_day || starts_at
  end

  def rsvp_open?
    published? &&
      requires_rsvp? &&
      rsvp_closes_at.future? &&
      !headcount_limit_reached? &&
      (rsvp_opens_at.nil? || rsvp_opens_at.past?)
  end

  def rsvp_closed?
    !rsvp_open?
  end

  def rsvps?
    rsvps.accepted.count.positive?
  end

  def shifts?
    event_shifts.count.positive?
  end

  ### temporal state

  def today?
    starts_at.today? && published?
  end

  def in_progress?
    published? && starts_at.past? && ends_at.future?
  end

  def chat
    super || Chat.find_or_create_by(chattable: self)
  end

  def chat?
    requires_rsvp
  end

  def cancellable?(member)
    published? && EventPolicy.new(member, self).cancel?
  end

  def deleteable?(member)
    persisted? && (cancelled? || draft?) && EventPolicy.new(member, self).delete?
  end

  def series?
    !new_record? && (series_children.count.positive? || series_siblings.count.positive?)
  end

  def rsvp_for(member)
    event_rsvps.find_by(unit_membership_id: member.id)
  end

  def rsvp_token_for(member)
    rsvp_tokens.find_by(unit_membership: member)
  end

  def series_children
    Event.where(series_parent_id: id)
  end

  def series_siblings
    return [] unless series_parent_id.present?

    Event.where(series_parent_id: series_parent_id)
  end

  def title_and_date
    "#{title} on #{starts_at.strftime('%b %d')}"
  end

  def destination
    address || location
  end

  def documents_required?
    document_types.present?
  end

  def non_respondents
    unit.unit_memberships.includes([:user]).order("users.last_name, users.first_name").status_active - unit_memberships
  end

  def non_invitees
    unit.unit_memberships.joins(:user).status_registered.order("users.last_name, users.first_name") - unit_memberships
  end

  def primary_location
    event_locations.select { |el| el.location_type == "arrival" || el.location_type == "activity" }.first&.location
  end

  def limits_headcount?
    max_total_attendees&.positive?
  end

  def location
    primary_location&.name
  end

  def address
    primary_location&.address
  end

  def map_address
    primary_location&.map_address
  end

  def find_location(location_type)
    event_locations.find_by(location_type: location_type)&.location
  end

  def full_address(location_type = nil)
    return primary_location&.full_address || "TBD" unless location_type.present?

    find_location(location_type)&.full_address
  end

  def initialize_chat
    Chat.find_or_create_by(chattable: self)
    chat
  end

  def mapping_address(location_type = nil)
    location = find_location(location_type || "arrival")
    location&.map_name || location&.address
  end

  def next
    unit.events.published.where("starts_at > ?", starts_at).order("starts_at ASC").first
  end

  def previous
    unit.events.published.where("starts_at < ?", starts_at).order("starts_at ASC").last
  end

  def packing_lists
    unit.packing_lists.where("id IN (?)", packing_list_ids.reject(&:zero?).uniq)
  end

  def packing_list_items
    packing_lists.map(&:packing_list_items).flatten.uniq
  end

  # @interface Chattable
  def chat_recipients
    result = rsvps.accepted.select { |r| r.member.smsable? }.collect(&:member)
    result.flatten.uniq
  end

  def chat_topic
    "#{title} (scheduled for #{starts_at.strftime('%b %d')})"
  end

  def organizer?(member)
    organizers.map(&:unit_membership).include?(member)
  end

  def organizers?
    organizers.any?
  end

  def reply_to
    return organizers.map(&:email_address_with_name).join(", ") if organizers?

    unit.members.admin.map(&:email_address_with_name).join(", ")
  end

  # implemented for Sendable to compute message recipients
  def audience
    "event_#{id}_attendees"
  end

  def notification_recipients
    with_guardians(requires_rsvp ? rsvps.accepted.collect(&:member) : unit.members.status_active)
  end

  private

  # create a weekly series based on @event
  # TODO: this is super-naive: it"s not idempotent, it doesn"t
  # handle things like updates, etc etc
  def create_series
    raise "Series duration cannot exceed one year" if repeats_until > starts_at.advance(years: 1)

    new_event = dup
    new_event.series_parent = self
    new_event.repeats_until = nil

    while new_event.starts_at < repeats_until
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end
end
# rubocop:enable Metrics/ClassLength
