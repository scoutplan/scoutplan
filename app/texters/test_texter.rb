# frozen_string_literal: true

# a Texter for sending test message
class TestTexter < MemberTexter
  def body
    ApplicationController.render(
      template: "texters/test",
      format: "text",
      assigns: { member: @member }
    )
  end
end
