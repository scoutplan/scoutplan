# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IcalEventImporter, type: :model do
  it "imports" do
    importer = IcalEventImporter.new
    importer.import
  end
end
