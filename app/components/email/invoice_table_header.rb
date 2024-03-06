# frozen_string_literal: true

# Email::InvoiceTableHeader component
# REQUIRED: none
# NOTES:
# - left_text: A default is given but you should override this, since it's static
# - right_text: By default, the current date — "07 August, 2023"
# - font: and color: accept EITHER a single value, or an array of 2 values (corresponding to the left/right text).
#   - this component then handles styling the respective part of text (see Example 2 below).
# - See invoice_table.rb for layout info
#
#
# Example 1 (simple):
# <%= render Email::InvoiceTable.new do |t| %>
#   <%= t.with_invoice_table_header(left_text: "INV-001") %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::InvoiceTable.new do |t| %>
#   <%= t.with_invoice_table_header(
#         left_text: "INV-001",
#         right_text: "Issued By: SAAS inc.",
#         font: [:arial, :georgia],
#         color: [Email::Colors::BLACK, Email::Colors::BLUE_700],
#       ) %>
#   ...
# <% end %>

class Email::InvoiceTableHeader < Email::Base
  def initialize(
    left_text: "INV-0001",
    right_text: Time.current.strftime("%-d %B, %Y"), # ex: 07 August, 2023
    font: InvoiceTableStyles::FONT,
    color: InvoiceTableStyles::HEADER_TEXT_COLOR
  )
    fonts_array = Array(font)
    colors_array = Array(color)

    @left_text = left_text
    @left_fonts = [fonts_array[0].to_s.titleize, InvoiceTableStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @left_color = colors_array[0]

    @right_text = right_text
    @right_fonts = [fonts_array[-1].to_s.titleize, InvoiceTableStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @right_color = colors_array[-1]
  end

  erb_template <<~ERB
    <tr>
      <td style="word-break: break-word; font-family: <%= @left_fonts %>; font-size: 16px;">
        <h3 style="margin-top: 0; color: <%= @left_color %>; font-size: 14px; font-weight: bold; text-align: left;" align="left"><%= @left_text %></h3>
      </td>
      <td style="word-break: break-word; font-family: <%= @right_fonts %>; font-size: 16px;">
        <h3 style="margin-top: 0; color: <%= @right_color %>; font-size: 14px; font-weight: bold; text-align: right;" align="right"><%= @right_text %></h3>
      </td>
    </tr>
  ERB
end
