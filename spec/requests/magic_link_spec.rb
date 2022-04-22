# frozen_string_literal: true

require "rails_helper"

describe "magic links", type: :request do
  it "rejects malformed tokens" do
    path = "/wp-admin.php"
    expect { get path }.to raise_exception(ActionController::RoutingError)
  end

  it "permits valid tokens" do
    member = FactoryBot.create(:member)
    path = unit_path(member.unit)
    magic_link = MagicLink.generate_link(member, path)
    expect { get "/#{magic_link.token}" }.not_to raise_exception
  end
end
