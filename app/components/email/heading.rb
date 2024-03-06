# frozen_string_literal: true

# Email::Heading component
# REQUIRED: none
# NOTES:
# - text: pass directly or as a |block|
# - align: left-aligned by default. override as needed (ie: align: "center")
#
#
# Example 1 (simple):
# <%= render Email::Heading.new(text: "Heading text") %>
#
# Example 2 (override styles):
# <%= render Email::Heading.new(
#         font: :arial,
#         size: "48px",
#         color: Email::Colors::GREEN_500,
#         bold: false,
#         align: "center",
#         margin: "24px auto"
#       ) do %>
#     Heading Text
#   <% end %>
#

class Email::Heading < Email::Base
  def initialize(
    text: nil,
    font: HeadingStyles::FONT,
    size: HeadingStyles::SIZE,
    letter_spacing: "0",
    color: HeadingStyles::COLOR,
    bold: true,
    align: "left",
    margin: "6px auto 18px auto"
  )
    @text = text # text to display. pass directly or as a |block|
    @fonts = [font.to_s.titleize, HeadingStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @size = size
    @letter_spacing = letter_spacing # prefer rem units for mobile compatibility
    @color = color
    @bold = bold
    @align = align
    @margin = margin # if you adjust size:, tweak margin: to make things look right
  end

  erb_template <<~ERB
    <h1 style="margin: <%= @margin %>; color: <%= @color %>; font-family: <%= @fonts %>; font-size: <%= @size %>; text-align: <%= @align %>; letter-spacing: <%= @letter_spacing %>; font-weight: <%= @bold ? "bold" : "normal" %>;" align="<%= @align %>">
      <%= @text.nil? ? content : @text %>
    </h1>
  ERB
end
