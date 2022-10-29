# frozen_string_literal: true

# a Texter for sending digests
class HelpTexter < UserTexter
  def body_text
    renderer.render(template: "member_texter/help", format: "text", assigns: { user: @user })
  end
end
