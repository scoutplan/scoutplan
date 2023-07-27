# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  belongs_to :author, class_name: "UnitMembership"
  has_one :unit, through: :author
  after_initialize :set_defaults

  # validates_presence_of :title

  alias_attribute :member, :unit_membership

  enum status: { draft: 0, queued: 1, sent: 2, pending: 3 }

  # serialize :recipient_details, Array

  # def author
  #   UnitMembership.unscoped { super }
  # end

  # https://stackoverflow.com/a/56437977/6756943
  def set_defaults
    self&.pin_until ||= 1.week.from_now
  end

  def event_cohort?
    recipients =~ /event_([0-9]+)_attendees/
  end

  def member_cohort?
    !event_cohort?
  end

  def send_now?
    !send_at&.future?
  end

  def active?
    sent? && deliver_via_digest && pin_until > Time.now
  end

  def editable?
    status != "sent"
  end

  def approvers
    unit.unit_memberships.message_approver
  end

  def recipients
    # # pull parameters
    # p = params.permit(:audience, :member_type, :member_status)
    # audience = p[:audience]
    # member_type = p[:member_type] == "youth_and_adults" ? %w[adult youth] : %w[adult]
    # member_status = p[:member_status] == "active_and_registered" ? %w[active registered] : %w[active]

    # # start building up the scope
    # scope = @unit.unit_memberships.joins(:user).order(:last_name)
    # scope = scope.where(member_type: member_type) # adult / youth

    # # filter by audience
    # if audience =~ EVENT_REGEXP
    #   event = Event.find($1)
    #   scope = scope.where(id: event.rsvps.pluck(:unit_membership_id))
    # elsif audience =~ TAG_REGEXP
    #   tag = ActsAsTaggableOn::Tag.find($1)
    #   scope = scope.tagged_with(tag.name)
    # else
    #   scope = scope.where(status: member_status) # active / friends & family
    # end

    # @recipients = scope.all

    # # ensure that parents are included if any children are included
    # parent_relationships = MemberRelationship.where(child_unit_membership_id: @recipients.map(&:id))
    # parents = UnitMembership.where(id: parent_relationships.map(&:parent_unit_membership_id))
    # @recipients += parents

    # # de-dupe it
    # @recipients.uniq!

    # # filter out non-emailable members
    # @recipients = @recipients.select(&:emailable?)
  end

  # private

  # def find_unit
  #   @unit = author.unit
  # end
end
