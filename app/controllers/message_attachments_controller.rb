# frozen_string_literal: true

class MessageAttachmentsController < UnitContextController
  before_action :find_attachment, only: [:destroy]

  # Uploads unattached Active Storage blobs for each uploaded file, then
  # renders the create.turbo_stream which, in turn, updates the Message UI with
  # blob IDs that get posted with the Message form. See
  # https://stackoverflow.com/questions/67176634/rails-active-storage-without-model
  #
  # If the user cancels the Message form, the blobs will be orphaned. The PurgeOrphanedUploads
  # job can be run to clean up orphaned blobs.
  # def create
  #   files = params[:files].reject(&:blank?)
  #   message_token = params[:message_token]
  #   @uploads = []

  #   files.each do |file|
  #     @uploads << { file: file, token: SecureRandom.hex(8) }
  #   end

  #   # render partial: "message_attachments/pending_uploads", format: "turbo_stream"

  #   @uploads.each do |upload|
  #     Turbo::StreamsChannel.broadcast_append_to(
  #       "message_#{message_token}",
  #       target:  "attachments_list",
  #       partial: "message_attachments/pending_upload",
  #       locals:  { upload: upload }
  #     )
  #   end

  #   @uploads.each do |upload|
  #     blob = ActiveStorage::Blob.create_and_upload!(io: upload[:file], filename: upload[:file].original_filename)
  #     upload[:blob_id] = blob.id

  #     Turbo::StreamsChannel.broadcast_append_to(
  #       "message_#{message_token}",
  #       target:  "attachments_list",
  #       partial: "message_attachments/completed_upload",
  #       locals:  { upload: upload }
  #     )
  #   end

  #   head :no_content
  # end

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
