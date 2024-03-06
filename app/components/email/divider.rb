# frozen_string_literal: true

# Email::Divider component
# REQUIRED: none
# NOTES:
# - margin: default value of "0 auto" will horizontally center divider. Adjust this value to left/right align it instead.
#
#
# Example 1 (simple):
# <%= render Email::Divider.new %>
#
# Example 2 (override styles):
# <%= render Email::Divider.new(
#         width: "25%",
#         color: Email::Colors::GRAY_800,
#         thickness: "24px",
#         margin: "0",
#       ) %>
#
class Email::Divider < Email::Base
  def initialize(
    width: DividerStyles::WIDTH,
    color: DividerStyles::COLOR,
    thickness: DividerStyles::THICKNESS,
    margin: "0 auto"
  )
    @width = width
    @color = color
    @thickness = thickness
    @margin = margin # by default, center the divider
  end

  erb_template <<~ERB
    <table class="divider" role="presentation" style="margin-top: 25px; padding-top: 25px; border-top-width: <%= @thickness %>; border-top-color: <%= @color %>; border-top-style: solid; width: <%= @width %>; margin: <%= @margin %>">
    </table>
  ERB
end
