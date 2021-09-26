class EventMailerPreview < ActionMailer::Preview
  def token_invitation_email
    EventMailer.with(token: nil).token_invitation_email
  end
end
