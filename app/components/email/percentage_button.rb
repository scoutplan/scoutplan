# frozen_string_literal: true

# Email::PercentageButton component [supports dark variant]
# REQUIRED: text:, href:
# NOTES:
# - Almost identical to the regular ::Button component, except it uses percentage-based widths.
#   - This makes it better for wide buttons, or ones that need to adapt to multiple viewports responsively.
#   - Only the width parameter is adjusted; The height: property behaves the same as the regular ::Button
# - href: needs to be an absolute url (good="https://example.com", bad="example.com")
#
#
# Example 1 (simple):
# <%= render Email::PercentageButton.new(
#           text: "Responsive Button",
#           href: "https://example.com",
#         ) %>
#
# Example 2 (override styles):
# <%= render Email::PercentageButton.new(
#     text: "Responsive button → ",
#     href: "https://example.com",
#     font: :arial,
#     color: Email::Colors::ORANGE_500,
#     text_color: Email::Colors::ORANGE_50,
#     text_size: "20px",
#     width: "50%",
#     height: "16px",
#     border_radius: "60px",
#     margin: "60px auto 0 auto",
#     shadow: "none"
#   ) %>
#
class Email::PercentageButton < Email::Base
  def initialize(
    text:,
    href:,
    font: ButtonStyles::FONT,
    color: ButtonStyles::BACKGROUND_COLOR,
    text_color: ButtonStyles::TEXT_COLOR,
    text_size: ButtonStyles::TEXT_SIZE,
    width: "100%",
    height: ButtonStyles::HEIGHT,
    border_radius: ButtonStyles::BORDER_RADIUS,
    bold: false,
    margin: "30px auto",
    shadow: ButtonStyles::SHADOW
  )
    @text = text
    @href = href # url for button to link to
    @fonts = [font.to_s.titleize, HeadingStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @color = color # background color
    @text_color = text_color
    @text_size = text_size
    @width = width # should be a %-age width
    @height = height
    @border_radius = border_radius # how round the button looks. "0px" = rectangle
    @font_weight = bold ? "bold" : "normal"
    @margin = margin # external spacing
    @shadow = shadow # use "none" for no shadow
  end

  erb_template <<~ERB
    <table align="center" width=<%= @width %> cellpadding="0" cellspacing="0" role="presentation" style="width: <%= @width %>; text-align: center; margin: <%= @margin %>; padding: 0;">
      <tr>
        <td align="center" style="word-break: break-word; font-family: <%= @fonts %>; font-size: <%= @text_size %>">
          <table width="100%" border="0" cellspacing="0" cellpadding="0" role="presentation">
            <tr>
              <td align="center" style="word-break: break-word; font-family: <%= @fonts %>; font-size: <%= @text_size %>;">
                <a href="<%= @href %>" class="f-fallback button" target="_blank" style="width: 100%; color: <%= @text_color %>; background-color: <%= @color %>; display: inline-block; text-decoration: none; font-weight: <%= @font_weight %>; border-radius: <%= @border_radius %>; box-shadow: <%= @shadow %>; -webkit-text-size-adjust: none; box-sizing: border-box; border-color: <%= @color %>; border-style: solid; border-width: <%= @height %> 4px;">
                  <%= @text %>
                </a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  ERB
end
