class MemberMailer < ApplicationMailer
  def invitation_email
    @member = params[:member]
    mail(to: @user.email, from: @unit.settings(:communication).from_email, subject: "#{@unit.name} Event Invitation: #{@event.title}")
  end

  def digest_email
    @member     = params[:member]
    @family     = @member.family
    @user       = @member.user
    @unit       = @member.unit
    @events     = @unit.events.published.future.upcoming
    @presenter  = EventPresenter.new
    mail(to: @user.email, from: @unit.settings(:communication).from_email, subject: "#{@unit.name} Digest")
  end
end
