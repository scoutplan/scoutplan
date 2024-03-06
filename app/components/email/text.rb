# frozen_string_literal: true

# Email::Text component
# REQUIRED: none
# NOTES:
# - text: pass directly or as a |block|
# - align: left-aligned by default. override as needed (ie: align: "center")
#
#
# Example 1 (simple):
# <%= render Email::Text.new(text: "Heading text") %>
#
# Example 2 (override styles):
# <%= render Email::Text.new(
#         font: :arial,
#         size: "24px",
#         color: Email::Colors::GREEN_500,
#         bold: true,
#         align: "center",
#         margin: "24px auto"
#       ) do %>
#     Body Text
#   <% end %>
#
class Email::Text < Email::Base
  def initialize(
    text: nil,
    font: TextStyles::FONT,
    size: TextStyles::SIZE,
    letter_spacing: "0",
    color: TextStyles::COLOR,
    bold: false,
    align: "left",
    margin: "4px 0px 18px 0px"
  )
    @text = text # pass directly or as a |block|
    @fonts = [font.to_s.titleize, TextStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @size = size
    @letter_spacing = letter_spacing # prefer rem units for mobile compatibility
    @color = color
    @font_weight = bold ? "bold" : "normal"
    @align = align
    @margin = margin
  end

  erb_template <<~ERB
    <p style="font-family: <%= @fonts %>;font-size: <%= @size %>; text-align: <%= @align %>; letter-spacing: <%= @letter_spacing %>; line-height: 1.625; color: <%= @color %>; margin: <%= @margin %>; font-weight: <%= @font_weight %>;">
      <%= @text.nil? ? content : @text %>
    </p>
  ERB
end
