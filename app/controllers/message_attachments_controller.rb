# frozen_string_literal: true

class MessageAttachmentsController < UnitContextController
  before_action :find_message, only: [:destroy]
  before_action :find_attachment, only: [:destroy]

  def create
    files = params[:files].reject(&:blank?)
    @uploads = []
    files.each do |file|
      filename = file.original_filename
      blob = ActiveStorage::Blob.create_and_upload!(io: file, filename: filename)
      @uploads << { filename: filename, blob_id: blob.id }
    end
  end

  def destroy
    @message.errors.add(:base, "Cannot delete attachments to sent messages") if @message.sent?
    @attachment.purge
  end

  private

  def find_attachment
    @attachment = @message.attachments.find(params[:id])
  end

  def find_message
    @message = @unit.messages.find(params[:message_id])
  end
end
