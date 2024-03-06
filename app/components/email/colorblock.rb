# frozen_string_literal: true

# Email::Colorblock component [supports dark variant]
# REQUIRED: none
# NOTES: none
#
#
# Example 1 (simple):
# <%= render Email::Colorblock.new do %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::Colorblock.new(
#   color: Email::Colors::GREEN_100,
#   border_color: Email::Colors::GREEN_700,
#   border_width: "12px",
#   border_radius: "48px",
#   border_style: "inset", # https://developer.mozilla.org/en-US/docs/Web/CSS/border-style
#   margin: "30px auto",
#   padding: "20px",
# ) do %>
# ...
# <% end %>
#
class Email::Colorblock < Email::Base
  def initialize(
    color: ColorblockStyles::BACKGROUND_COLOR,
    border_color: ColorblockStyles::BORDER_COLOR,
    border_width: ColorblockStyles::BORDER_WIDTH,
    border_radius: ColorblockStyles::BORDER_RADIUS,
    border_style: ColorblockStyles::BORDER_STYLE,
    margin: ColorblockStyles::MARGIN,
    padding: ColorblockStyles::PADDING
  )
    @color = color # background color of colorblock
    @border_color = border_color
    @border_width = border_width
    @border_style = border_style
    @border_radius = border_radius
    @padding = padding # spacing inside colorblock
    @margin = margin # spacing outside colorblock

    # set the default fonts on the colorblock. shouldn't actually style anything, but needed for email client compatibility
    @fonts = [ContainerStyles::DEFAULT_FONT.to_s.titleize, ContainerStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
  end

  erb_template <<~ERB
    <table class="colorblock" align="center" width="100%" cellpadding="0" cellspacing="0" role="presentation" style="margin: <%= @margin %>; width: 100%;">
      <tr>
        <td class="colorblock_content" style="word-break: break-word; font-family: <%= @fonts %>; font-size: 16px; background-color: <%= @color %>; padding: <%= @padding %>; border: <%= @border_width %> <%= @border_style %> <%= @border_color %>; border-radius: <%= @border_radius %>;" bgcolor="<%= @color %>">
          <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
            <tr>
              <td class="colorblock_inner" style="word-break: break-word; font-family: <%= @fonts %>; font-size: 16px; padding: 0;">
                <span class="f-fallback">
                  <%= content %>
                </span>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  ERB
end
