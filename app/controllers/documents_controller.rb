class DocumentsController < ApplicationController
  def create
    document_type_id = params[:document_type_id]
    received = params[:received] == "true"

    event_rsvp_id = params[:event_rsvp_id]
    rsvp = EventRsvp.find(event_rsvp_id)
    @event = rsvp.event
    if received
      rsvp.documents.find_or_create_by(document_type_id: document_type_id)
    else
      rsvp.documents.find_by(document_type_id: document_type_id).destroy!
      puts "destroyed"
    end

    respond_to do |format|
      format.html { redirect_to unit_event_organize_path(@unit, @rsvp.event) }
      format.turbo_stream
    end
  end
end
