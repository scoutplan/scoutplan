# frozen_string_literal: true

require "rails_helper"

RSpec.describe "events/partials/form/_event_location", type: :view do
  let(:unit)           { create(:unit) }
  let(:location)       { create(:location, unit: unit) }
  let(:event)          { create(:event, unit: unit) }
  let(:event_location) { create(:event_location, event: event, location: location, location_type: "arrival") }

  # simulates a form submission of the rendered fields, with the trash can checked
  def submitted_params(html)
    query = Nokogiri::HTML(html).css("input").filter_map do |input|
      next if input["type"] == "checkbox" && input["name"].exclude?("_destroy")

      "#{CGI.escape(input["name"])}=#{CGI.escape(input["value"].to_s)}"
    end.join("&")

    ActionController::Parameters.new(Rack::Utils.parse_nested_query(query))
  end

  before do
    render partial: "events/partials/form/event_location",
           locals: { event_location: event_location, event_location_counter: 0 }
  end

  it "names its fields so they nest under event_locations_attributes" do
    params = submitted_params(rendered).require(:event)

    expect(params[:event_locations_attributes]["0"].to_unsafe_h).to include(
      "id"            => event_location.id.to_s,
      "location_type" => "arrival",
      "location_id"   => location.id.to_s,
      "_destroy"      => "1"
    )
  end

  it "permits the nested attributes through EventsController's strong params" do
    params = submitted_params(rendered).require(:event)
                                       .permit(event_locations_attributes: [:id, :location_type, :location_id,
                                                                            :event_id, :url, :_destroy])

    expect(params[:event_locations_attributes]["0"][:_destroy]).to eq("1")
  end

  it "destroys the event location when those attributes are assigned" do
    params = submitted_params(rendered).require(:event)
                                       .permit(event_locations_attributes: [:id, :location_type, :location_id,
                                                                            :event_id, :url, :_destroy])

    expect { event.update!(params) }.to change { event.event_locations.count }.by(-1)
  end

  it "points the trash can label at the destroy checkbox" do
    doc = Nokogiri::HTML(rendered)
    checkbox = doc.at_css("input[type=checkbox]")

    expect(doc.at_css("label")["for"]).to eq(checkbox["id"])
  end
end
