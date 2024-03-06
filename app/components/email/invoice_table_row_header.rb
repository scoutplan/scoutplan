# frozen_string_literal: true

# Email::InvoiceTableRowHeader component
# REQUIRED: none
# NOTES:
# - font: and color: accept EITHER a single value, or an array of 2 values (corresponding to the left/right text).
#   - this component then handles styling the respective part of text (see Example 2 below).
# - See invoice_table.rb for layout info
#
#
# Example 1 (simple):
# <%= render Email::InvoiceTable.new do |t| %>
#   ...
#   <%= t.with_invoice_table_row_header %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::InvoiceTable.new do |t| %>
#   ...
#   <%= t.with_invoice_table_row_header(
#         left_text: "Item",
#         right_text: "Price",
#         font: [:arial, :georgia],
#         color: [Email::Colors::BLACK, Email::Colors::BLUE_700],
#       ) %>
#   ...
# <% end %>

class Email::InvoiceTableRowHeader < Email::Base
  def initialize(
    left_text: "Description",
    right_text: "Amount",
    font: InvoiceTableStyles::FONT,
    color: InvoiceTableStyles::ROW_HEADER_TEXT_COLOR
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
      <th align="left" style="font-family: <%= @left_fonts %>; font-size: 16px; padding-bottom: 8px; border-bottom-width: 1px; border-bottom-color: #EAEAEC; border-bottom-style: solid;">
        <p class="f-fallback" style="font-size: 12px; line-height: 1.625; color: <%= @left_color %>; margin: 0;"><%= @left_text %></p>
      </th>
      <th align="right" style="font-family: <%= @right_fonts %>; font-size: 16px; padding-bottom: 8px; border-bottom-width: 1px; border-bottom-color: #EAEAEC; border-bottom-style: solid;">
        <p class="f-fallback" style="font-size: 12px; line-height: 1.625; color: <%= @right_color %>; margin: 0;"><%= @right_text %></p>
      </th>
    </tr>
  ERB
end
