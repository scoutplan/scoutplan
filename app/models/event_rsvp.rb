# frozen_string_literal: true

class EventRsvp < ApplicationRecord
  include Notifiable

  belongs_to :event
  belongs_to :unit_membership
  belongs_to :respondent, class_name: "UnitMembership"

  before_save :enforce_approval_policy
  after_commit :approve!

  has_many :documents, as: :documentable, dependent: :destroy

  validates_uniqueness_of :event, scope: :unit_membership
  validates :response, presence: { message: "requires a response" }
  validate :common_unit?
  validate :response_allowed?

  enum response: { declined: 0, accepted: 1, declined_pending: 2, accepted_pending: 3 }

  alias_attribute :member, :unit_membership

  delegate :reply_to, to: :event
  delegate :organizers?, to: :event
  delegate_missing_to :unit_membership

  scope :ordered, -> { includes(unit_membership: :user).order("users.last_name, users.first_name") }
  scope :youth, -> { joins(:unit_membership).merge(UnitMembership.youth) }
  scope :adult, -> { joins(:unit_membership).merge(UnitMembership.adult) }

  def common_unit?
    errors.add(:event, "and Member must belong to the same Unit") unless event.unit == member.unit
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
    ap "#enforce_approval_policy"
    return unless requires_approval?

    self.response = case response
                    when "accepted" then "accepted_pending"
                    when "declined" then "declined_pending"
                    else response
                    end
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

  def approved?
    pending_approval?(response_was) && !pending_approval?
  end

  def approve!
    ap "Sending approval confirmation to the kid" if approved?
  end
end
