class EventRsvp < ApplicationRecord
  RESPONSE_OPTIONS = { accepted: 1, accepted_pending: 3, declined: 0, declined_pending: 2 }.freeze

  include Notifiable

  belongs_to :event
  belongs_to :unit_membership
  belongs_to :member, class_name: "UnitMembership", foreign_key: "unit_membership_id"
  belongs_to :respondent, class_name: "UnitMembership"

  before_save :enforce_approval_policy

  has_many :documents, as: :documentable, dependent: :destroy
  has_one :unit, through: :unit_membership
  has_one :user, through: :unit_membership
  validates_uniqueness_of :event, scope: :unit_membership
  validates :response, presence: { message: "requires a response" }
  validate :common_unit?
  validate :response_allowed?

  enum response: RESPONSE_OPTIONS

  delegate :reply_to, to: :event
  delegate :organizers?, to: :event
  delegate_missing_to :unit_membership

  scope :ordered, -> { includes(unit_membership: :user).order("users.last_name, users.first_name") }
  scope :youth, -> { joins(:unit_membership).merge(UnitMembership.youth) }
  scope :adult, -> { joins(:unit_membership).merge(UnitMembership.adult) }
  scope :accepted_intent, -> { where(response: %w[accepted accepted_pending]) }
  scope :declined_intent, -> { where(response: %w[declined declined_pending]) }
  scope :recent, -> { where("event_rsvps.updated_at > ?", 24.hours.ago) }

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

  def cost
    member.youth? ? event.cost_youth : event.cost_adult
  end

  def enforce_approval_policy
    return unless requires_approval?

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
