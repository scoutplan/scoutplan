# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "#format_phone" do
    it "formats a bare ten-digit number" do
      expect(helper.format_phone("9148647317")).to eq("(914) 864-7317")
    end

    it "ignores punctuation already present" do
      expect(helper.format_phone("914-864-7317")).to eq("(914) 864-7317")
    end

    it "strips a leading country code" do
      expect(helper.format_phone("19148647317")).to eq("(914) 864-7317")
    end

    it "passes through anything it does not recognise" do
      expect(helper.format_phone("+44 20 7946 0958")).to eq("+44 20 7946 0958")
      expect(helper.format_phone("ext. 4")).to eq("ext. 4")
    end

    it "handles nil and blank" do
      expect(helper.format_phone(nil)).to be_nil
      expect(helper.format_phone("")).to eq("")
    end
  end

  describe "#phone_link" do
    it "renders a formatted tel: link" do
      html = helper.phone_link("9148647317")

      expect(html).to have_css("a[href='tel:9148647317']", text: "(914) 864-7317")
    end

    it "returns nothing when there is no number" do
      expect(helper.phone_link(nil)).to be_nil
      expect(helper.phone_link("")).to be_nil
    end
  end
end
