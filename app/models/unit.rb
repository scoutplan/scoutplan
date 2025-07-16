# rubocop:disable Metrics/ClassLength
class Unit < ApplicationRecord
  BUSINESS_HOURS = [9, 18].freeze
  include Seasons, DistributionLists

  has_one :payment_account

  has_many :documents, as: :documentable
  has_many :events
  has_many :event_categories
  has_many :external_integrations, dependent: :destroy
  has_many :unit_memberships
  has_many :users, through: :unit_memberships
  has_many :locations, through: :events
  has_many :news_items
  has_many :tasks, as: :taskable
  has_many :locations
  has_many :messages, through: :unit_memberships
  has_many :packing_lists, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :payments, through: :events
  has_many :wiki_pages

  has_one_attached :logo

  validates_presence_of :name
  validates_presence_of :location
  validates_presence_of :slug
  validates_uniqueness_of :email
  validates_uniqueness_of :slug

  alias_method :memberships, :unit_memberships
  alias_method :members, :unit_memberships
  alias_method :categories, :event_categories

  after_create :populate_categories
  before_validation :generate_slug

  enum :status, { active: "active", inactive: "inactive" }

  delegate :transaction_fees_covered_by, to: :payment_account

  has_settings class_name: "UnitSettings" do |s|
    s.key :appearance, defaults: { main_color: "#003F87" }
    s.key :communication, defaults: { config_timestamp: nil, digest: true, rsvp_nag: "true", event_reminders: true,
                                      digest_day_of_week: SendWeeklyDigestJob::DEFAULT_DAY_OF_WEEK,
                                      digest_hour_of_day: SendWeeklyDigestJob::DEFAULT_HOUR_OF_DAY,
                                      rsvp_nag_day_of_week: RsvpNagJob::DEFAULT_DAY_OF_WEEK,
                                      rsvp_nag_hour_of_day: RsvpNagJob::DEFAULT_HOUR_OF_DAY }
    s.key :locale, defaults: { time_zone: "Eastern Time (US & Canada)",
                               meeting_location: nil, meeting_address: nil }
    s.key :utilities, defaults: { fire_scheduled_tasks: false }
    s.key :documents, defaults: { home_layout: "[]" }
  end

  def attachments
    ActiveStorage::Attachment.includes(:blob)
                             .with_all_variant_records
                             .where(record_type: "Event", record_id: events.collect(&:id))
  end

  def self.current
    @@current_unit
  end

  def self.current=(unit)
    @@current_unit = unit
  end

  def self.find_by_slug(slug)
    find_by(slug: slug)
  end

  def self.find_by_slug!(slug)
    find_by!(slug: slug)
  end

  def self.find_by_id_or_slug(id_or_slug)
    find_by(id: id_or_slug) || find_by(slug: id_or_slug)
  end

  def from_address
    "#{slug}@#{ENV.fetch('EMAIL_DOMAIN')}"
  end

  def messages
    # members.collect(&:messages)
    Message.where(author_id: members.collect(&:id))
  end

  def membership_for(user)
    members.includes(:parent_relationships, :child_relationships).find_by(user: user)
  end

  def name_and_location
    "#{name} #{location}"
  end

  def next_event
    @next_event ||= events.future.published.order(:starts_at).first
  end

  def payments_enabled?
    payment_account.present? && payment_account.active?
  end

  def planner
    Planner.new(self)
  end

  def default_event_category
    categories.first
  end

  def short_name
    name.split.map { |word| word.numeric? ? word : word.first }.join
  end

  def time_zone
    settings(:locale).time_zone
  end

  # given a datetime, returns the nearest datetime that is within business hours
  def in_business_hours(datetime)
    dt = datetime.in_time_zone(time_zone)
    if dt.hour < BUSINESS_HOURS.first
      dt.change(hour: BUSINESS_HOURS.first, min: 0, sec: 0).utc
    elsif dt.hour >= BUSINESS_HOURS.last
      dt.change(hour: BUSINESS_HOURS.last, min: 0, sec: 0).utc
    else
      datetime
    end
  end

  def datetime_in_business_hours(datetime)
    in_business_hours(datetime)
  end

  def to_s
    name
  end

  # acts like .update, but for settings as defined at the top of the class
  def update_settings(params)
    params.each do |key, value|
      settings(key.to_sym).update!(value)
    end
  end

  private

  # TODO: move this somewhere else
  def populate_categories
    EventCategory.seeds.each do |category|
      event_categories.create(
        name:  category.name,
        glyph: category.glyph,
        color: category.color
      )
    end
  end

  def generate_slug
    return if slug.present? || name.blank?

    candidate = base = name.parameterize
    candidate = base + "-#{SecureRandom.hex(6)}" while Unit.where(slug: candidate).exists?

    update(slug: candidate)
  end
end
# rubocop:enable Metrics/ClassLength
