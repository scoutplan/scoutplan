# frozen_string_literal: true

# Email::Image component
# REQUIRED: src:, alt_text:
# NOTES:
# - src: url to the image
# - alt_text: description of your image. Required since some email clients block images by default (so your users will only see the alt text)
# - width_px: width of your image in pixels. Required for accurate display in Outlook
#
#
# Example 1 (simple):
# <%= render Email::Image.new(
#         src: "https://images.unsplash.com/photo-1586920740280-e7da670f7cb7",
#         alt_text: "Circuit board",
#       ) %>
#
# Example 2 (override styles):
# <%= render Email::Image.new(
#         src: "https://images.unsplash.com/photo-1586920740280-e7da670f7cb7",
#         alt_text: "Circuit board",
#         width: "50%",
#         margin: "50px auto",
#         width_px: "450",
#         border_radius: "0px",
#       ) %>
#
class Email::Image < Email::Base
  def initialize(
    src:,
    alt_text:,
    width: "90%",
    margin: "30px auto",
    width_px: "600",
    border_radius: "0px",
    display: :block
  )
    @src = src
    @alt_text = alt_text # image alt text, displayed if image cannot be shown
    @width = width # use this to adjust the width of your images.
    @width_px = width_px # width (in pixels) of your image. Needed for your image to display correctly in Outlook.
    @margin = margin
    @border_radius = border_radius
    @display = display.to_s
  end

  erb_template <<~ERB
    <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="<%= @width %>" style="margin: <%= @margin %>;">
      <tr>
        <td style="">
        <img src="<%= @src %>" width="<%= @width_px %>" height="" alt="<%= @alt_text %>" border="0" style="width: <%= @width %>; max-width: <%= @width_px %>px; height: auto; font-family: sans-serif; font-size: 15px; line-height: 15px; color: #555555; margin: auto; display: <%= @display %>; border-radius: <%= @border_radius %>;">
        </td>
      </tr>
    </table>
  ERB
end
