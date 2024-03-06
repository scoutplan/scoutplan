# frozen_string_literal: true

# Email::Columns component
# REQUIRED: none
# NOTES:
# - By default, gives 2 columns of equal width
# - Widths is an array of the column widths (as a percentage of 100%)
#   - Widths should sum to 100 or less
#   - Widths.length should equal cols (same number of widths as cols)
#
#
# Example 1 (simple):
# <%= render Email::Columns.new do |c| %>
#   <%= c.with_column do %><% end %>
#   <%= c.with_column do %><% end %>
# <% end %>
#
# Example 2 (override styles):
# <%= render Email::Columns.new(
#   cols: 4,
#   widths: [10, 40, 40, 10],
#   margin: "24px auto"
# ) do |c| %>
#   <%= c.with_column do %><% end %>
#   <%= c.with_column do %><% end %>
#   <%= c.with_column do %><% end %>
#   <%= c.with_column do %><% end %>
# <% end %>
#
class Email::Columns < Email::Base
  renders_many :columns

  def initialize(
    cols: 2,
    widths: [50, 50],
    margin: nil
  )
    @margin = margin
    @widths = widths

    raise "Error: widths should sum to 100 or less" unless widths.sum <= 100
    raise "Error: not enough widths. Need #{cols} width values for #{cols} columns" unless widths.length == cols
  end

  erb_template <<~ERB
    <table align="center" width="100%" cellpadding="0" cellspacing="0" role="presentation" style="width: 100%; margin: <%= @margin %>;">
        <tr>
            <td style="padding: 0px; background-color: inherit;">
                <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <% @widths.each_with_index do |col_width, idx| %>
                          <td width="<%= col_width %>%">
                              <%= columns[idx] %>
                          </td>
                        <% end %>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
  ERB
end
