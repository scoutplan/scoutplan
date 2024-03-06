# frozen_string_literal: true

# Email::ResetStylesheet component
# Reference Link — https://github.com/JayOram/email-css-resets
#
# Applies some reset styles to your emails (via insertion into the Email::Container components),
# to override the default styles that many email clients will try to apply.
# ex: without this reset, all links appear blue and underlined in Webkit browsers
#
class Email::ResetStylesheet < Email::Base
  def initialize
    # override default link (<a> tag) styling
    @link_color = ResetStylesheetStyles::LINK_COLOR
    @link_text_decoration = ResetStylesheetStyles::LINK_TEXT_DECORATION
  end

  erb_template <<~ERB
    a {
      color: <%= @link_color %>;
      text-decoration: <%= @link_text_decoration %>;
      font-size: inherit;
      font-weight: inherit;
      line-height: inherit;
    }
  ERB
end
