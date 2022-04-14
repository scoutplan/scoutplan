# frozen_string_literal: true

require "uri"

# utilities for sending Announcements and Messages
module MessagingHelper
  # given a UnitMembership and a message text,
  # find all local links and replace them with
  # MagicLinks. Local links are those that start
  # with http[s]://ENV['APP_HOST']
  #
  # substitute_links(todd, "Visit https://go.scoutplan.org/units/1/events/2 to learn more.")
  # => "Visit https://go.scoutplan.org/1234567890abc to learn more."
  def substitute_links(member, text)
    paths = URI.extract(text)
    paths.each do |full_path|
      uri = URI(full_path)
      path = uri.path
      magic_link = MagicLink.generate_link(member, path)
      text.gsub!(full_path, magic_link_url(magic_link.token))
    end
    text
  end
end
