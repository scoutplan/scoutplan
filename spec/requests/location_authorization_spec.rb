# frozen_string_literal: true

require "rails_helper"

describe "location authorization", type: :request do
  let(:unit) { FactoryBot.create(:unit) }
  let(:admin) { FactoryBot.create(:member, :admin, unit: unit) }
  let(:plain_member) { FactoryBot.create(:member, unit: unit) }
  let(:location) { FactoryBot.create(:location, unit: unit, name: "Ward Pound Ridge") }

  describe "DELETE /u/:unit/locations/:id" do
    it "lets a unit admin delete their own location" do
      login_as(admin.user, scope: :user)

      delete "/u/#{unit.to_param}/locations/#{location.id}"

      expect(Location.exists?(location.id)).to be(false)
    end

    it "refuses a plain member of the same unit" do
      login_as(plain_member.user, scope: :user)

      delete "/u/#{unit.to_param}/locations/#{location.id}"

      expect(Location.exists?(location.id)).to be(true)
    end

    it "refuses an admin of another unit" do
      other_admin = FactoryBot.create(:member, :admin)
      login_as(other_admin.user, scope: :user)

      delete "/u/#{other_admin.unit.to_param}/locations/#{location.id}"

      expect(Location.exists?(location.id)).to be(true)
    end
  end

  describe "POST /u/:unit/locations.json (create from the event form)" do
    let(:event) { FactoryBot.create(:event, unit: unit) }
    let(:organizer) { FactoryBot.create(:member, unit: unit) }

    def create_location(name:, event_id: nil, **attrs)
      post "/u/#{unit.to_param}/locations.json",
        params: {location: {name: name, **attrs}, event_id: event_id}
    end

    it "returns the new location as JSON" do
      login_as(admin.user, scope: :user)

      create_location(name: "Parish Hall", address: "1 Main St")

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["name"]).to eq("Parish Hall")
      expect(body["needs_detail"]).to be(false)
    end

    it "reports a location created without an address as needing detail" do
      login_as(admin.user, scope: :user)

      create_location(name: "Somewhere")

      expect(response.parsed_body["needs_detail"]).to be(true)
    end

    it "lets a non-admin organizer of the event create one" do
      event.event_organizers.create!(unit_membership: organizer)
      login_as(organizer.user, scope: :user)

      expect { create_location(name: "Trailhead", event_id: event.id) }
        .to change { unit.locations.count }.by(1)
    end

    it "refuses a plain member with no event context" do
      login_as(plain_member.user, scope: :user)

      expect { create_location(name: "Trailhead") }.not_to change { unit.locations.count }
    end

    it "refuses a plain member who cannot edit the named event" do
      event # the event factory creates a location of its own; build it up front
      login_as(plain_member.user, scope: :user)

      create_location(name: "Trailhead", event_id: event.id)

      expect(response).to have_http_status(:redirect)
      expect(unit.locations.where(name: "Trailhead")).to be_empty
    end
  end

  describe "POST /u/:unit/event_locations" do
    let(:event) { FactoryBot.create(:event, unit: unit) }

    def post_event_location(as_unit:, params:)
      post "/u/#{as_unit.to_param}/event_locations", params: {event_location: params}
    end

    it "renders the row for an admin of the owning unit" do
      login_as(admin.user, scope: :user)

      post_event_location(as_unit: unit,
        params: {event_id: event.id, location_id: location.id,
                 location_type: "arrival"})

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ward Pound Ridge")
    end

    it "does not disclose a location belonging to another unit" do
      foreign = FactoryBot.create(:location, unit: FactoryBot.create(:unit), name: "Secret Bunker")
      login_as(admin.user, scope: :user)

      post_event_location(as_unit: unit,
        params: {event_id: event.id, location_id: foreign.id,
                 location_type: "arrival"})

      expect(response.body).not_to include("Secret Bunker")
    end

    it "refuses a member who cannot edit the event" do
      login_as(plain_member.user, scope: :user)

      post_event_location(as_unit: unit,
        params: {event_id: event.id, location_id: location.id,
                 location_type: "arrival"})

      expect(response.body).not_to include("Ward Pound Ridge")
    end

    it "still accepts an online location, which carries no location_id" do
      login_as(admin.user, scope: :user)

      post_event_location(as_unit: unit,
        params: {event_id: event.id, location_type: "online",
                 url: "https://zoom.us/j/123"})

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("zoom.us")
    end
  end
end
