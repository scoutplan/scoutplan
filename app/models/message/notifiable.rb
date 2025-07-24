# frozen_string_literal: true

module Message::Notifiable
  extend ActiveSupport::Concern

  EVENT_REGEXP = /event_(\d+)_attendees/
  TAG_REGEXP = /tag_(\d+)_members/

  # given a list of members, return a list of members and their guardians
  def with_guardians(members)
    parent_relationships = MemberRelationship.where(child_unit_membership_id: members.map(&:id))
    parents = UnitMembership.where(id: parent_relationships.pluck(:parent_unit_membership_id))
    results = members + parents
    results.uniq
  end

  def recipients
    scope = unit.unit_memberships.joins(:user).order(:last_name)
    scope = scope.where(member_type: member_type == "youth_and_adults" ? %w[adult youth] : %w[adult]) # adult / youth

    if event_cohort?
      event = Event.find(::Regexp.last_match(1))
      scope = scope.where(id: event.rsvps.pluck(:unit_membership_id))

    elsif audience =~ TAG_REGEXP
      tag = ActsAsTaggableOn::Tag.find(::Regexp.last_match(1))
      scope = scope.tagged_with(tag.name)
    else
      scope = scope.where(status: member_status == "active_and_registered" ? %w[active registered] : %w[active])
    end

    results = with_guardians(scope.all)

    results.select { |r| r.contactable_via?(:email) }
  end

  def event_cohort?
    audience =~ EVENT_REGEXP
  end
end
