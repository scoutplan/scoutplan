class EventAttachmentsController < ApplicationController
  def update
    @event = Event.find(params[:event_id])
    attach_files
    render turbo_stream: [
      turbo_stream.update("attachments", partial: "events/partials/form/attachments")
    ]
  end

  private

  def attach_files
    params[:event][:attachments]&.each do |attachment|
      @event.attachments.attach(attachment)
    end
  end
end
