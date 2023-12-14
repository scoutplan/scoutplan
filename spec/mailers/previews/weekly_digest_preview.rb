# Preview all emails at http://localhost:3000/rails/mailers/weekly_digest
class WeeklyDigestPreview < ActionMailer::Preview
  def notification
    unit = Unit.first
    recipient = unit.members.first
    WeeklyDigestMailer.with(recipient: recipient, unit: unit).weekly_digest_notification
  end
end
