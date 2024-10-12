require "active_model/attribute_assignment"

class EventCancellation
  include ActiveModel::AttributeAssignment

  attr_reader :events
  attr_accessor :message_audience, :message, :cancel_series, :disposition

  def initialize(event)
    @events = [event]
    @events.concat(event.series.where("starts_at > ?", event.starts_at)) if event.series?
  end

  def cancel!
    events.each do |event|
      case disposition
      when "cancel"
        event.update(status: "cancelled")
      when "unpublish"
        event.update(status: "draft")
      when "delete"
        event.destroy
      end
    end
  end
end
