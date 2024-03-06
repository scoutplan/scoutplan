# frozen_string_literal: true

# Email::MastheadText component
# REQUIRED: text:, href:
# NOTES:
# - Masthead components sit above the main Email container
# - Only 1 masthead can be rendered into a container
#
#
# Example 1 (simple):
# <%= render Email::Bg::Container.new do |email| %>
#   <% email.with_masthead_text(text: "Example" , href: "https://example.com") %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::Bg::Container.new do |email| %>
# <% email.with_masthead_text(
#       text: "Example",
#       href: "https://example.com",
#       font: :arial,
#       color: Email::Colors::BLUE_500,
#       text_shadow: "0",
#     ) %>
#   ...
# <% end %>
#
class Email::MastheadText < Email::Base
  def initialize(
    text:,
    href:,
    font: MastheadTextStyles::FONT,
    color: MastheadTextStyles::COLOR,
    text_shadow: MastheadTextStyles::TEXT_SHADOW
  )
    @text = text
    @href = href
    @fonts = [font.to_s.titleize, MastheadTextStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @color = color
    @text_shadow = text_shadow
  end

  erb_template <<~ERB
    <tr>
      <td class="email-masthead" style="word-break: break-word; font-family: <%= @fonts %>; font-size: 16px; text-align: center; padding: 25px 0;" align="center">
        <a href="<%= @href %>" class="f-fallback email-masthead_name" style="color: <%= @color %>; font-size: 16px; font-weight: bold; text-decoration: none; text-shadow: <%= @text_shadow %>;">
          <%= @text %>
        </a>
      </td>
    </tr>
  ERB
end
