# frozen_string_literal: true

namespace :sp do
  desc "Create member tokens"
  task create_member_tokens: :environment do
    UnitMembership.all.each do |member|
      next if member.token.present?

      magic_link = MagicLink.where(unit_membership: member, path: "icalendar").order(created_at: :desc)&.first
      if magic_link.present?
        member.update(token: magic_link.token)
      else
        member.regenerate_token
      end
    end
  end

  desc "Delete ical magic links"
  task delete_ical_magic_links: :environment do
    MagicLink.where(path: "icalendar").destroy_all
  end
end
