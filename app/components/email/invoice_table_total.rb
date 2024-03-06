# frozen_string_literal: true

# Email::InvoiceTableTotal component
# REQUIRED: right_text:
# NOTES:
# - font: and color: accept EITHER a single value, or an array of 2 values (corresponding to the left/right text).
#   - this component then handles styling the respective part of text (see Example 2 below).
# - See invoice_table.rb for layout info
#
#
# Example 1 (simple):
# <%= render Email::InvoiceTable.new do |t| %>
#   ...
#   <%= t.with_invoice_table_total(right_text: "$30") %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::InvoiceTable.new do |t| %>
#   ...
#   <%= t.with_invoice_table_total(
#         left_text: "Final Price:",
#         right_text: "$58 USD",
#         font: :arial,
#         color: Email::Colors::RED_700,
#       ) %>
#   ...
# <% end %>

class Email::InvoiceTableTotal < Email::Base
  def initialize(
    left_text: "Total:",
    right_text:,
    font: InvoiceTableStyles::FONT,
    color: InvoiceTableStyles::TOTAL_TEXT_COLOR
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
      <td width="75%" valign="middle" style="word-break: break-word; font-family: <%= @fonts %>; font-size: 15px; padding-top: 15px; border-top-width: 1px; border-top-color: #EAEAEC; border-top-style: solid;">
        <p class="f-fallback" style="font-size: 15px; line-height: 1.625; text-align: right; font-weight: bold; font-family: <%= @left_fonts %>; color: <%= @left_color %>; margin: 0; padding: 0 15px 0 0;" align="right"><%= @left_text %></p>
      </td>
      <td width="25%" valign="middle" style="word-break: break-word; font-family: <%= @fonts %>; font-size: 15px; padding-top: 15px; border-top-width: 1px; border-top-color: #EAEAEC; border-top-style: solid;">
        <p class="f-fallback" style="font-size: 15px; line-height: 1.625; text-align: right; font-weight: bold; font-family: <%= @right_fonts %>; color: <%= @left_color %>; margin: 0;" align="right"><%= @right_text %></p>
      </td>
    </tr>
  ERB
end
