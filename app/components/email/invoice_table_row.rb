# frozen_string_literal: true

# Email::InvoiceTableRow component
# REQUIRED: left_text:, right_text:
# NOTES:
# - font: and color: accept EITHER a single value, or an array of 2 values (corresponding to the left/right text).
#   - this component then handles styling the respective part of text (see Example 2 below).
# - See invoice_table.rb for layout info
# - For more info on how we render the array items,
#   - visit: https://viewcomponent.org/guide/slots.html#rendering-collections
#
#
# Example 1 (simple):
# <%= render Email::InvoiceTable.new do |t| %>
#   ...
#   <%= t.with_invoice_table_rows([
#       { left_text: "Item 1", right_text: "$10" },
#       { left_text: "Item 2", right_text: "£20" },
#     ]) %>
#   ...
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::InvoiceTable.new do |t| %>
#   ...
#   <%= t.with_invoice_table_rows([
#         { left_text: "Item 1", right_text: "$10", font: [:arial, :georgia], color: Email::Colors::RED_500 },
#         { left_text: "Item 2", right_text: "£20", font: :arial, [color: Email::Colors::BLUE_500, color: Email::Colors::GRAY_500] },
#       ]) %>
#   ...
# <% end %>
# #
class Email::InvoiceTableRow < Email::Base
  def initialize(
    left_text:,
    right_text:,
    font: InvoiceTableStyles::FONT,
    color: InvoiceTableStyles::ROW_TEXT_COLOR,
    padding: "10px 0"
  )
    fonts_array = Array(font)
    colors_array = Array(color)

    @left_text = left_text
    @left_fonts = [fonts_array[0].to_s.titleize, InvoiceTableStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @left_color = colors_array[0]

    @right_text = right_text
    @right_fonts = [fonts_array[-1].to_s.titleize, InvoiceTableStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @right_color = colors_array[-1]

    @padding = padding
  end

  erb_template <<~ERB
    <tr>
      <td width="75%" style="word-break: break-word; font-family: <%= @left_fonts %>; font-size: 15px; color: <%= @left_color %>; line-height: 18px; padding: <%= @padding %>;"><%= @left_text %></td>
      <td width="25%" style="word-break: break-word; font-family: <%= @right_fonts %>; font-size: 15px; color: <%= @right_color %>; text-align: right;" align="right"><%= @right_text %></td>
    </tr>
  ERB
end
