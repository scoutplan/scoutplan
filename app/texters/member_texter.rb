class MemberTexter < Textris::Base
  default from: ENV['TWILIO_NUMBER']

  def digest(params)
    # return unless member.settings(:communication).via_sms

    @member = params[:member]
    ap @member.phone
    @unit = @member.unit
    @this_week_events = @unit.events.published.this_week
    text to: @member.phone
  end
end
