# frozen_string_literal: true

# Email::InvoiceTable component
# REQUIRED: none
# NOTES:
# - This component wraps all other ::InvoiceTable components
# - It renders the table layout, then inserts the the other components.
# - It expects a table header, row header, array of rows, and a final total
#
#
# Example 1 (simple):
# <%= render Email::InvoiceTable.new do |t| %>
#   <%= t.with_invoice_table_header(left_text: "INV-001") %>
#   <%= t.with_invoice_table_row_header %>
#   <%= t.with_invoice_table_rows([
#         { left_text: "Item 1", right_text: "$10" },
#         { left_text: "Item 2", right_text: "£20" },
#       ]) %>
#   <%= t.with_invoice_table_total(right_text: "$30") %>
# <% end %>
#
# LAYOUT:
# |----------------- InvoiceTable ------------------|
# | Header.left_text              Header.right_text |
# |                                                 |
# | RowHeader.left_text        RowHeader.right_text |
# | ------------------------------------------------|
# | Row.left_text                    Row.right_text |
# | Row.left_text                    Row.right_text |
# | Row.left_text                    Row.right_text |
# | ------------------------------------------------|
# |              Total.left_text   Total.right_text |
# |-------------------------------------------------|
#
class Email::InvoiceTable < Email::Base
  renders_one :invoice_table_header, Email::InvoiceTableHeader
  renders_one :invoice_table_row_header, Email::InvoiceTableRowHeader
  renders_many :invoice_table_rows, Email::InvoiceTableRow
  renders_one :invoice_table_total, Email::InvoiceTableTotal

  def initialize(
    font: InvoiceTableStyles::FONT,
    padding: "35px 0",
    body_padding: "25px 0 0"
  )
    @fonts = [font.to_s.titleize, HeadingStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @padding = padding
    @body_padding = body_padding
  end

  erb_template <<~ERB
    <table width="100%" cellpadding="0" cellspacing="0" style="width: 100% !important; margin: 0 auto; padding: <%= @padding %>;">
      <%= invoice_table_header %>
      <tr>
        <td colspan="2" style="word-break: break-word; font-family: <%= @fonts %>; font-size: 15px;">
          <table width="100%" cellpadding="0" cellspacing="0" style="width: 100% !important; margin: 0; padding: <%= @body_padding %>;">
            <%= invoice_table_row_header %>
            <% invoice_table_rows.each do |row| %>
              <%= row %>
            <% end %>
            <% if invoice_table_total? %>
              <%= invoice_table_total %>
            <% end %>
          </table>
        </td>
      </tr>
    </table>
  ERB
end
