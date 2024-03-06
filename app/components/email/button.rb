# frozen_string_literal: true

# Email::Button component [supports dark variant]
# REQUIRED: text:, href:
# NOTES:
# - Border-based button component, good for most situations.
#   - If you need a responsive button (ie: a full-width button regardless of viewport), look at ::PercentageButton
# - href: needs to be an absolute url (good="https://example.com", bad="example.com")
#
#
# Example 1 (simple):
# <%= render Email::Button.new(
#           text: "Simple Button",
#           href: "https://example.com",
#         ) %>
#
# Example 2 (override styles):
# <%= render Email::Button.new(
#     text: "Advanced button → ",
#     href: "https://example.com",
#     font: :arial,
#     color: Email::Colors::ORANGE_500,
#     text_color: Email::Colors::ORANGE_50,
#     text_size: "20px",
#     width: "48px",
#     height: "16px",
#     border_radius: "60px",
#     margin: "60px auto 0 auto",
#     shadow: "none"
#   ) %>
#
class Email::Button < Email::Base
  def initialize(
    text:,
    href:,
    font: ButtonStyles::FONT,
    color: ButtonStyles::BACKGROUND_COLOR,
    text_color: ButtonStyles::TEXT_COLOR,
    text_size: ButtonStyles::TEXT_SIZE,
    width: ButtonStyles::WIDTH,
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
    @width = width
    @height = height
    @border_radius = border_radius # how round the button looks. "0px" = rectangle
    @font_weight = bold ? "bold" : "normal"
    @margin = margin # external spacing
    @shadow = shadow
  end

  erb_template <<~ERB
    <table align="center" width="100%" cellpadding="0" cellspacing="0" role="presentation" style="width: 100%; text-align: center; margin: <%= @margin %>; padding: 0;">
      <tr>
        <td align="center" style="word-break: break-word; font-family: <%= @fonts %>; font-size: <%= @text_size %>">
          <table width="100%" border="0" cellspacing="0" cellpadding="0" role="presentation">
            <tr>
              <td align="center" style="word-break: break-word; font-family: <%= @fonts %>; font-size: <%= @text_size %>;">
                <a href="<%= @href %>" class="f-fallback button" target="_blank" style="color: <%= @text_color %>; background-color: <%= @color %>; display: inline-block; text-decoration: none; font-weight: <%= @font_weight %>; border-radius: <%= @border_radius %>; box-shadow: <%= @shadow %>; -webkit-text-size-adjust: none; box-sizing: border-box; border-color: <%= @color %>; border-style: solid; border-width: <%= @height %> <%= @width %>;">
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
