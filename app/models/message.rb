# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  # presentation attributes
  attr_accessor :target_active_members, :target_supporters, :target_adults_only, :target_member_ids

  belongs_to :author, class_name: "UnitMembership"
  has_one :unit, through: :author
  has_many :message_recipients
  alias_attribute :member, :unit_membership
  enum status: { draft: 0, sent: 1, archived: 2 }

  # generate a list of actual members who'll receive this message
  def resolve_recipients
    find_unit
    recipients = []
    recipients << @unit.members.status_active if target_active_members
    recipients << @unit.members.status_registered if target_supporters
    recipients = recipients.select(&:adult?) if target_adults_only
    recipients << @unit.members.where("id IN ?", target_member_ids)

    # make sure active parent(s) are copied when addressing youths
    recipients.each do |recipient|
      next unless recipient.youth?

      recipient.parent_relationships.each do |parent|
        next unless parent.active?

        recipients << parent
      end
    end

    # finally, de-dupe the list and return it
    recipients.uniq
  end

  private

  def find_unit
    @unit = author.unit
  end
end
