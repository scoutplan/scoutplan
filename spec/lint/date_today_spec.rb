# frozen_string_literal: true

require "rails_helper"

# Guards against reintroducing `Date.today`, which returns the system-local
# date instead of the Rails Time.zone date. See Event#timezone_snapshot for
# the one intentional exception (a diagnostic that compares both).
RSpec.describe "lint: Date.today usage", type: :lint do
  ALLOWED_PATHS = [
    "app/models/event.rb"  # diagnostic snapshot intentionally records Date.today vs Date.current
  ].freeze

  it "does not appear in app/ or lib/ outside the allowlist" do
    offenders = Dir.glob(Rails.root.join("{app,lib}/**/*.{rb,slim,erb}")).flat_map do |path|
      rel = Pathname.new(path).relative_path_from(Rails.root).to_s
      next [] if ALLOWED_PATHS.include?(rel)

      File.readlines(path).each_with_index.filter_map do |line, idx|
        "#{rel}:#{idx + 1}: #{line.strip}" if line.include?("Date.today")
      end
    end

    expect(offenders).to be_empty, <<~MSG
      Found Date.today usage. Use Date.current (or Time.zone.today) instead — it respects Time.zone.

      #{offenders.join("\n")}
    MSG
  end
end
