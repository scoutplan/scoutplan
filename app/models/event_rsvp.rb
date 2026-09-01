class EventRsvp < ApplicationRecord
  RESPONSE_OPTIONS = { accepted: 1, accepted_pending: 3, declined: 0, declined_pending: 2 }.freeze

  include Notifiable

  # Deliberately not `touch: true`. That moved events.updated_at, which EventReminderJob,
  # RsvpLastCallJob and OrganizerPrepJob all read as a staleness guard -- so every RSVP scheduled a
  # duplicate reminder that later bailed, and every RSVP took a write on the shared event row.
  # #record_rsvp_activity below carries the same signal for cache keys instead.
  belongs_to :event
  belongs_to :unit_membership
  belongs_to :member, class_name: "UnitMembership", foreign_key: "unit_membership_id"
  belongs_to :respondent, class_name: "UnitMembership"

  before_save :enforce_approval_policy
  after_commit :record_rsvp_activity

  has_many :documents, as: :documentable, dependent: :destroy
  has_one :unit, through: :unit_membership
  has_one :user, through: :unit_membership
  validates_uniqueness_of :event, scope: :unit_membership
  validates :response, presence: { message: "requires a response" }
  validate :common_unit?
  validate :response_allowed?

  enum :response, RESPONSE_OPTIONS

  delegate :reply_to, to: :event
  delegate :organizers?, to: :event
  delegate_missing_to :unit_membership

  scope :ordered, -> { includes(unit_membership: :user).order("users.last_name, users.first_name") }
  scope :youth, -> { joins(:unit_membership).merge(UnitMembership.youth) }
  scope :adult, -> { joins(:unit_membership).merge(UnitMembership.adult) }
  scope :accepted_intent, -> { where(response: %w[accepted accepted_pending]) }
  scope :declined_intent, -> { where(response: %w[declined declined_pending]) }
  scope :recent, -> { where("event_rsvps.updated_at > ?", 24.hours.ago) }

  # Stamps the event so anything caching RSVP-derived output (the agenda dashboard tiles) can key
  # on it. update_column skips callbacks and does not move updated_at, so this does not re-enqueue
  # the reminder jobs the way `touch: true` did.
  def record_rsvp_activity
    return if destroyed_by_association # the event itself is going away
    return unless event&.persisted?

    event.update_column(:rsvps_updated_at, Time.current)
  end

  ### validations
  def common_unit?
    errors.add(:event, "and Member must belong to the same Unit") unless event.unit == unit_membership.unit
  end

  def response_allowed?
    return true if EventRsvpPolicy.new(respondent, self).create?

    errors.add(:event_rsvp, "respondent is not authorized to create or edit this RSVP")
  end

  def document?(document_type)
    documents.find_by(document_type: document_type)
  end

  def documents_received?
    (event.document_types.required - documents.collect(&:document_type)).blank?
  end

  def done?
    return true unless response == "accepted"
    return false if event.requires_payment? && !paid
    return false if event.documents_required? && !documents_received?

    true
  end

  def action_pending?
    !done?
  end

  ### payment methods
  def cost
    return 0 unless accepted? || accepted_pending?

    adult? ? event.cost_adult : event.cost_youth
  end

  def payments
    event.payments.where(unit_membership: unit_membership)
  end

  def balance_due
    cost - amount_paid
  end

  def amount_paid
    payments.sum(&:amount_in_dollars)
  end

  def paid_in_full?
    balance_due.zero?
  end

  def payment_status
    return :in_full if balance_due.zero?
    return :partial if amount_paid.positive?

    :none
  end

  ### approval methods
  def enforce_approval_policy
    return unless requires_approval?

    puts "I am here"
    self.response = case response
                    when "accepted" then "accepted_pending"
                    when "declined" then "declined_pending"
                    else response
                    end
    self.approved = pending_approval?(response_was) && !pending_approval?
  end

  def self_responded?
    respondent == member
  end

  def approvers
    member.parents
  end

  def requires_approval?
    respondent.youth?
  end

  def pending_approval?(val = nil)
    %w[declined_pending accepted_pending].include?(val || response)
  end

  def recent?
    updated_at > 1.day.ago
  end
end
