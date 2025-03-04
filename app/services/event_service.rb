# frozen_string_literal: true

class EventService < ApplicationService
  def initialize(event, params = {})
    @event = event
    @params = params
    super()
  end

  # given a document_library_ids params in the form of a comma separated string,
  # find the attachments and attach them to the event
  def process_library_attachments
    return unless @params[:document_library_ids].present?

    attachment_ids = @params[:document_library_ids].split(",").map(&:to_i)
    attachment_ids.each do |attachment_id|
      source_attachment = ActiveStorage::Attachment.find(attachment_id)
      @event.attachments.attach(source_attachment.blob)
    end
  end
end
