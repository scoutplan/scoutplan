# frozen_string_literal: true

# a calendar event
# rubocop:disable Metrics/ClassLength
class Event < ApplicationRecord
  include Remindable
  extend DateTimeAttributes
  date_time_attrs_for :starts_at, :ends_at
  attr_accessor :repeats, :notify_members, :notify_recipients, :notify_message, :document_library_ids

  LOCATION_TYPES = {
    departure: "departure",
    staging: "staging",
    activity: "activity"
  }.freeze

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
  has_many :payments
  has_many :photos
  has_many :members, through: :event_rsvps
  has_many :rsvp_tokens, dependent: :destroy
  has_many :sub_events, class_name: "Event", foreign_key: "parent_event_id"

  has_one :chat, as: :chattable, dependent: :destroy

  has_rich_text :description
  has_many_attached :attachments
  has_paper_trail versions: {
    scope: -> { order("id desc") }
  }

  accepts_nested_attributes_for :event_locations, allow_destroy: true
  accepts_nested_attributes_for :event_organizers, allow_destroy: true

  alias_attribute :rsvps, :event_rsvps
  alias_attribute :category, :event_category
  alias_attribute :activities, :event_activities
  alias_attribute :organizers, :event_organizers
  alias_attribute :shifts, :event_shifts

  validates_presence_of :title, :starts_at, :ends_at
  validate :dates_are_subsequent
  validates :attachments,
            content_type: ["image/png", "image/jpg", "image/jpeg", "image/gif", "application/pdf",
                           "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                           "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                           "application/vnd.ms-powerpoint", "application/vnd.openxmlformats-officedocument.presentationml.presentation"],
            size: { less_than: 2.megabytes, message: "must be less than 2 MB" }

  enum status: { draft: 0, published: 1, cancelled: 2, archived: 3 }

  # TODO: clean up this mess
  scope :past,          -> { where("starts_at < ?", Date.today) }
  scope :future,        -> { where("starts_at > ?", Date.today) }
  scope :recent,        -> { where("starts_at BETWEEN ? AND ?", 4.weeks.ago, Date.today)}
  scope :this_week,     -> { where("starts_at BETWEEN ? AND ?", Time.now, 7.days.from_now.at_end_of_day.in_time_zone) }
  scope :upcoming,      -> { where("starts_at BETWEEN ? AND ?", Time.now, 35.days.from_now) }
  scope :coming_up,     -> { where("starts_at BETWEEN ? AND ?", 7.days.from_now, 35.days.from_now) }
  scope :rsvp_required, -> { where(requires_rsvp: true) }
  scope :today,         -> { where("starts_at BETWEEN ? AND ?", Time.zone.now.beginning_of_day, Time.zone.now.at_end_of_day) }
  scope :imminent, -> {
    where("starts_at BETWEEN ? AND ?",
          Time.zone.now.hour < 12 ? Time.zone.now.middle_of_day : Time.zone.now.end_of_day,
          Time.zone.now.hour < 12 ? Time.zone.now.end_of_day : Time.zone.now.end_of_day + 12.hours)
  }

  scope :recent_and_future, -> { where("starts_at > ?", 4.weeks.ago) }
  scope :recent_and_upcoming, -> { where("starts_at BETWEEN ? AND ?", 4.weeks.ago, 35.days.from_now)}

  acts_as_taggable_on :tags

  def category_name
    event_category.name
  end

  def dates_are_subsequent
    errors.add(:ends_at, "must be after start_date") if starts_at > ends_at
    errors.add(:rsvp_closes_at, "must be before start_date") if requires_rsvp && rsvp_closes_at > starts_at
  end

  def full_title
    "#{unit.name} #{title}"
  end

  def organizable?
    requires_rsvp
  end

  def past?
    ends_at.past?
  end

  def requires_payment?
    (cost_adult + cost_youth).positive?
  end

  # override getter
  def rsvp_closes_at
    read_attribute(:rsvp_closes_at) || starts_at
  end

  def rsvp_open?
    status == "published" && requires_rsvp && rsvp_closes_at > DateTime.now
  end

  def rsvps?
    rsvps.accepted.count.positive?
  end

  def shifts?
    event_shifts.count.positive?
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

  # members who haven't RSVP'ed
  def non_respondents
    unit.members.status_active - rsvps.collect(&:member)
  end

  def non_invitees
    unit.members.status_registered - rsvps.collect(&:member)
  end

  def primary_location
    # (event_locations.find_by(location_type: "arrival")&.location || event_locations.find_by(location_type: "activity")&.location)
    event_locations.select { |el| el.location_type == "arrival" || el.location_type == "activity" }.first&.location
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
    organizers.map(&:member).include?(member)
  end

  # used by Sendable to compute message recipients
  def audience
    "event_#{id}_attendees"
  end

  # def to_param
  #   [id, title].join(" ").parameterize
  # end

  private

  # create a weekly series based on @event
  # TODO: this is super-naive: it"s not idempotent, it doesn"t
  # handle things like updates, etc etc
  def create_series
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
