# frozen_string_literal: true

# Email::Bg::Container component [supports dark variant]
# Wraps all other components into an email layout
# REQUIRED: none
# NOTES:
# - Omitting a ::Masthead component will render nothing (and shift the container up)
# - Bg::Container renders content on a 570px wide @color card, on a @surrounds_color background
# - supports @margin, so you can adjust the top/bottom margin of the container (note that some Outlook clients will ignore this margin).
#   - by default has 60px bottom margin so the container doesn't hit the bottom of the email.
#
#
# Example 1 (simple):
# <%= render Email::Bg::Container.new do |email| %>
#   ...
# <% end %>
#
#
class Email::Bg::Container < Email::Base
  # the masthead component is rendered above your email
  # pass either a Email::MastheadText or a Email::MastheadImage
  renders_one :masthead_component, types: {
    text: {renders: Email::MastheadText, as: :masthead_text},
    image: {renders: Email::MastheadImage, as: :masthead_image}
  }

  def initialize(
    default_font: ContainerStyles::DEFAULT_FONT,
    color: ContainerStyles::COLOR,
    surrounds_color: ContainerStyles::SURROUNDS_COLOR,
    border_radius: ContainerStyles::BORDER_RADIUS,
    padding: ContainerStyles::PADDING,
    margin: "0 auto 60px auto", # 0 top, 60px bottom, auto left/right (gives some room between container bottom and end of email)
    dark_mode_enabled: DarkStyles::ENABLED
  )
    @default_fonts = [default_font.to_s.titleize, HeadingStyles::FALLBACK_FONT.to_s.dasherize].join(", ")
    @color = color
    @surrounds_color = surrounds_color
    @border_radius = border_radius
    @padding = padding # padding inside the container
    @margin = margin # external container margin. left/right margin should be "auto" for centered container.
    @dark_mode_enabled = dark_mode_enabled
  end

  erb_template <<~ERB
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" style="color-scheme: light dark; supported-color-schemes: light dark;">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="x-apple-disable-message-reformatting" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="color-scheme" content="light dark" />
        <meta name="supported-color-schemes" content="light dark" />
        <title></title>
        <style type="text/css" rel="stylesheet" media="all">
          /* Base ------------------------------ */
          <%= render Email::ResetStylesheet.new %>

          /*Media Queries ------------------------------ */
          @media only screen and (max-width: 500px) {
            .button {
              width: 100% !important;
              text-align: center !important;
            }
          }

          @media only screen and (max-width: 600px) {
            .email-body_inner,
            .email-footer {
              width: 100% !important;
            }
          }

          <% if @dark_mode_enabled %>
            @media (prefers-color-scheme: dark) {
            body,
            .email-body,
            .email-masthead {
                background-color: <%= DarkStyles::CONTAINER_SURROUNDS_COLOR %> !important;
              }

            @media (prefers-color-scheme: dark) {
              .email-body_inner,
              .email-content,
              .email-wrapper,
              .email-footer {
                background-color: <%= DarkStyles::CONTAINER_COLOR %> !important;
                color: <%= DarkStyles::CONTAINER_TEXT_COLOR %> !important;
              }
              p,
              ul,
              ol,
              blockquote,
              h1,
              h2,
              h3,
              span {
                color: <%= DarkStyles::CONTAINER_TEXT_COLOR %> !important;
              }
              .colorblock_content {
                background-color: <%= DarkStyles::COLORBLOCK_COLOR %> !important;
              }
              .email-masthead_name {
                text-shadow: none !important;
                color: <%= DarkStyles::CONTAINER_TEXT_COLOR %> !important;
              }
              .button {
                color: <%= DarkStyles::BUTTON_TEXT_COLOR %> !important;
                background-color: <%= DarkStyles::BUTTON_COLOR %> !important;
                border-color: <%= DarkStyles::BUTTON_COLOR %> !important;
              }
            }

            :root {
              color-scheme: light dark;
              supported-color-schemes: light dark;
            }
          <% end %>
        </style>
        <!--[if mso]>
          <style type="text/css">
            .f-fallback  {
              font-family: Arial, sans-serif;
            }
          </style>
        <![endif]-->
      </head>
      <body style="width: 100% !important; height: 100%; -webkit-text-size-adjust: none; font-family: <%= @default_fonts %>; background-color: <%= @surrounds_color %>; color: #51545E; margin: 0;" bgcolor="<%= @surrounds_color %>">
        <table class="email-wrapper" width="100%" cellpadding="0" cellspacing="0" role="presentation" style="width: 100%; background-color: <%= @surrounds_color %>; margin: 0; padding: 0;" bgcolor="<%= @surrounds_color %>">
          <tr>
            <td align="center" style="word-break: break-word; font-family: <%= @default_fonts %>; font-size: 16px;">
              <table class="email-content" width="100%" cellpadding="0" cellspacing="0" role="presentation" style="width: 100%; margin: 0; padding: 0;">
                <tr>
                  <% if masthead_component %>
                    <%= masthead_component %>
                  <% end %>
                </tr>
                <!-- Email Body -->
                <tr>
                  <td class="email-body" width="570" cellpadding="0" cellspacing="0" style="word-break: break-word; font-family: <%= @default_fonts %>; font-size: 16px; width: 100%; margin: 0; padding: 0;">
                    <table class="email-body_inner" align="center" width="570" cellpadding="0" cellspacing="0" role="presentation" style="width: 570px; min-width: 570px; max-width: 570px; background-color: <%= @color %>; margin: <%= @margin %>; padding: 0; border-radius: <%= @border_radius %>;" bgcolor="<%= @color %>">
                      <!-- Body content -->
                      <tr>
                        <td class="content-cell" style="word-break: break-word; font-family: <%= @default_fonts %>; font-size: 16px; padding: <%= @padding %>;">
                          <div class="f-fallback">
                            <%= content %>
                          </div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
    </html>
  ERB
end
