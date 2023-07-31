class AttachmentsController < UnitContextController
  before_action :find_message
  before_action :find_attachment, only: [:destroy]

  def create
    params[:message][:attachments].each do |attachment|
      @message.attachments.attach(attachment)
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
