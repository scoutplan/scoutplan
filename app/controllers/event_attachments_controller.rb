class EventAttachmentsController < UnitContextController
  def destroy
    find_attachment
    return unless @attachment && EventAttachmentPolicy.new(current_member, @attachment).destroy?

    ap @attachment

    @attachment.purge

    render turbo_stream: [
      turbo_stream.remove("attachment_#{params[:id]}")
    ]
  end

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

  def find_attachment
    event = current_unit.events.find(params[:event_id])
    type = params[:type]

    if type == "private_attachments"
      @attachment = event.private_attachments.find(params[:id])
    elsif type == "attachments"
      @attachment = event.attachments.find(params[:id])
    end
  end
end
