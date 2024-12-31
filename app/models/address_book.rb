# frozen_string_literal: true

class AddressBook
  attr_reader :unit, :entries, :members

  def initialize(unit)
    @unit = unit
    @entries = []
    @members = @unit.unit_memberships
                    .includes(:setting_objects, user: :setting_objects)
                    .order("users.last_name, users.first_name")
    build_distribution_lists
    build_events
    build_members
  end

  def build_distribution_lists
    build_distribution_list("all", "Everyone in #{unit.name}", "everyone",
                            members.select(&:contactable?))
    build_distribution_list("active", "Active members", "everyone", members do |m|
      m.status_active? && m.contactable?
    end)
    build_distribution_list("adults", "Active adults", "everyone", members do |m|
      m.status_active? && m.contactable? && m.adult?
    end)
  end

  def build_distribution_list(key, name, keywords, members)
    description = "#{members.count} contactable members"
    @entries << AddressBookDistributionListEntry.new(key: key, name: name, keywords: keywords,
                                                     description: description)
  end

  def build_events
    events = unit.events.recent_and_upcoming.rsvp_required.with_accepted_rsvps
    return if events.empty?

    @entries += events.map { |event| AddressBookEventEntry.new(event) }
  end

  def build_members
    return if members.empty?

    @entries += members.map { |member| AddressBookMemberEntry.new(member) }
  end
end
