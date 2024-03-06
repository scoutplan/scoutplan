# frozen_string_literal: true

# Email::MastheadImage component
# REQUIRED: src:, alt_text:
# NOTES:
# - Masthead components sit above the main Email container
# - Only 1 masthead can be rendered into a container
# - src: url to the image
# - alt_text: description of your image. Required since some email clients block images by default (so your users will only see the alt text)
# - width_px: and height_px: should be set for correct Outlook rendering (otherwise your image might appear stretched)
#
#
# Example 1 (simple):
# <%= render Email::Bg::Container.new do |email| %>
#   <% email.with_masthead_image(
#       src: "https://railsnotesui.xyz/logo.png",
#       alt_text: "RailsNotes UI Logo",
#     ) %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::Bg::Container.new do |email| %>
#    <% email.with_masthead_image(
#      src: "https://railsnotesui.xyz/logo.png",
#      alt_text: "RailsNotes UI Logo",
#      width_px: "100",
#      height_px: "30",
#    ) %>
#   ...
# <% end %>
#
class Email::MastheadImage < Email::Base
  def initialize(
    src:,
    alt_text:,
    width_px: "200",
    height_px: "50"
  )
    @src = src
    @alt_text = alt_text # image alt text, displayed if image cannot be shown
    @width_px = width_px
    @height_px = height_px
  end

  erb_template <<~ERB
    <tr>
      <td class="email-masthead" style="word-break: break-word; font-family: sans-serif; font-size: 16px; text-align: center; padding: 25px 0;" align="center">
        <img src="<%= @src %>" width="<%= @width_px %>" height="<%= @height_px %>" alt="<%= @alt_text %>" border="0" style="height: auto; font-family: sans-serif; font-size: 15px; line-height: 15px; color: #555555;">
      </td>
    </tr>
  ERB
end
