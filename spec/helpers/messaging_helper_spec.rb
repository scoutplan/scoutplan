# frozen_string_literal: true

require "rails_helper"

RSpec.describe MessagingHelper, type: :helper do
  it "replaces app links with magic links in plain text" do
    member = FactoryBot.create(:member)
    unit = member.unit
    event = FactoryBot.create(:event, unit: unit)
    path = unit_event_url(unit, event, host: ENV["APP_HOST"])
    text = "Please click #{path} for details."
    new_text = substitute_links(member, text)
    magic_link = MagicLink.last
    expect(new_text).to include(magic_link_url(token: magic_link.token))
  end

  it "replaces app links with magic links in HTML" do
    member = FactoryBot.create(:member)
    unit = member.unit
    event = FactoryBot.create(:event, unit: unit)
    path = unit_event_url(unit, event, host: ENV["APP_HOST"])
    text = %(<p>Please click <a href="#{path}">here</a> for details.</p>)
    new_text = substitute_links(member, text)
    magic_link = MagicLink.last
    expect(new_text).to include(magic_link_url(token: magic_link.token))
  end
end
