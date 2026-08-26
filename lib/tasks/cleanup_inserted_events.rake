# frozen_string_literal: true

# One-off cleanup for draft events accidentally created by the spreadsheet row-insert control.
#
# The insertion strip in app/views/events/partials/spreadsheet/_event.slim spanned the full row
# width and sat above the Published toggle, so publishing a row could POST to
# spreadsheet_rows#create instead. Those events are identified here by their PaperTrail `create`
# version, and only removed when they still look untouched.
#
# Dry run (default):
#   bin/rails sp:cleanup_inserted_events UNIT_ID=42 SINCE=2026-08-25
#
# Narrow to one actor / title:
#   bin/rails sp:cleanup_inserted_events UNIT_ID=42 MEMBERSHIP_ID=1234 TITLE="Camping Trip"
#
# Actually delete:
#   bin/rails sp:cleanup_inserted_events UNIT_ID=42 SINCE=2026-08-25 APPLY=1
module InsertedEventCleanup
  # Reasons an event looks like it has been used for real. Empty means it is safe to delete.
  def self.in_use_reasons(event)
    reasons = []
    version_count = event.versions.count
    sub_event_count = Event.unscoped.where(parent_event_id: event.id).count

    reasons << "edited (#{version_count} versions)"          if version_count > 1
    reasons << "#{event.event_rsvps.count} rsvps"            if event.event_rsvps.exists?
    reasons << "#{event.documents.count} documents"          if event.documents.exists?
    reasons << "#{event.payments.count} payments"            if event.payments.exists?
    reasons << "#{event.photos.count} photos"                if event.photos.exists?
    reasons << "#{event.event_organizers.count} organizers"  if event.event_organizers.exists?
    reasons << "#{sub_event_count} sub-events"               if sub_event_count.positive?
    reasons << "has description"                             if event.description&.body&.to_plain_text.present?
    reasons
  end
end

namespace :sp do
  desc "Report (or delete, with APPLY=1) draft events accidentally inserted from the spreadsheet view"
  task cleanup_inserted_events: :environment do
    apply         = ENV["APPLY"].present?
    unit_id       = ENV["UNIT_ID"].presence
    membership_id = ENV["MEMBERSHIP_ID"].presence
    title_match   = ENV["TITLE"].presence
    since         = ENV["SINCE"].present? ? Time.zone.parse(ENV["SINCE"]) : 2.days.ago
    through       = ENV["UNTIL"].present? ? Time.zone.parse(ENV["UNTIL"]) : Time.current

    versions = PaperTrail::Version.where(item_type: "Event", event: "create")
                                  .where(created_at: since..through)
    versions = versions.where(whodunnit: membership_id) if membership_id

    candidates = Event.where(id: versions.select(:item_id))
    candidates = candidates.where(unit_id: unit_id) if unit_id
    candidates = candidates.where(title: title_match) if title_match
    candidates = candidates.where(status: :draft)

    puts "Window:      #{since} .. #{through}"
    puts "Filters:     unit=#{unit_id || 'any'} membership=#{membership_id || 'any'} title=#{title_match || 'any'}"
    puts "Create rows: #{versions.count}, still-draft events: #{candidates.count}"
    puts ""

    deletable = []
    skipped   = []

    candidates.includes(:unit, :event_category).each do |event|
      reasons = InsertedEventCleanup.in_use_reasons(event)
      reasons.empty? ? deletable << event : skipped << [event, reasons]
    end

    unless skipped.empty?
      puts "SKIPPING #{skipped.count} event(s) that show signs of real use:"
      skipped.each do |event, reasons|
        puts format("  #%-7d %-28s %s  (%s)", event.id, event.title.to_s.truncate(28),
                    event.starts_at.to_date, reasons.join(", "))
      end
      puts ""
    end

    if deletable.empty?
      puts "Nothing to delete."
      next
    end

    puts "#{apply ? 'DELETING' : 'WOULD DELETE'} #{deletable.count} event(s):"
    deletable.each do |event|
      version = versions.find_by(item_id: event.id)
      actor   = UnitMembership.find_by(id: version&.whodunnit)&.short_display_name
      puts format("  #%-7d unit=%-5d %-28s %s  created %s by %s",
                  event.id, event.unit_id, event.title.to_s.truncate(28), event.starts_at.to_date,
                  event.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                  actor || "membership #{version&.whodunnit || '?'}")
    end

    unless apply
      puts ""
      puts "Dry run. Re-run with APPLY=1 to destroy these events."
      next
    end

    destroyed = 0
    ActiveRecord::Base.transaction do
      deletable.each do |event|
        event.destroy!
        destroyed += 1
      end
    end
    puts ""
    puts "Destroyed #{destroyed} event(s)."
  end
end
