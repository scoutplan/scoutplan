# frozen_string_literal: true

# Email::Footer component
# REQUIRED: none
# NOTES:
# - Footer for the end of your email (put links, extra info etc.)
# - MUST be rendered as the final component. Will cause any following elements to render oddly (try it).
# - Expects to be passed a block containing other components / your content.
#
#
# Example 1 (simple):
# <%= render Email::Footer.new do %>
#   By Harrison.
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::Footer.new(
#     font: :arial,
#     padding: "15px auto",
#     text_size: "12px",
#     text_color: Email::Colors::ORANGE_500
#   ) do %>
#   By Harrison, Creator of <%= link_to "RailsNotes", "https://railsnotes.xyz" %> and <%= link_to "RailsNotes UI", "https://railsnotesui.xyz" %>.
# <% end %>
#
class Email::Footer < Email::Base
  def initialize(
    font: FooterStyles::FONT,
    padding: FooterStyles::PADDING,
    text_size: FooterStyles::TEXT_SIZE,
    text_color: FooterStyles::TEXT_COLOR,
    text_align: FooterStyles::TEXT_ALIGN
  )
    @fonts = [font.to_s.titleize, HeadingStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @padding = padding
    @text_size = text_size # by default ::Footer text is smaller than regular text
    @text_color = text_color
    @text_align = text_align
  end

  erb_template <<~ERB
    <tr>
      <td style="word-break: break-word; font-family: <%= @fonts %>; font-size: <%= @text_size %>;">
        <table class="email-footer" align="center" width="570" cellpadding="0" cellspacing="0" role="presentation" style="width: 570px; text-align: center; margin: 0 auto; padding: 0;">
          <tr>
            <td class="content-cell" align="center" style="word-break: break-word; font-family: <%= @fonts %>; font-size: <%= @text_size %>; color: <%= @text_color %>; text-align: <%= @text_align %>; padding: <%= @padding %>;">
              <%= content %>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  ERB
end
