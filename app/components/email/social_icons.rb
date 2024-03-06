# frozen_string_literal: true

# Email::SocialIcons component [supports dark variant]
# REQUIRED: none
# NOTES:
# - pass the URLs of the icons you want to render — icons with a nil value wont get rendered
# - adjust the spacing between icons with the "icons_spacing" property
# - if you want to use different icons, you can manually adjust the URLs in @icon_data
#
#
# Example 1 (simple):
# <%= render Email::SocialIcons.new(
#           instagram_url: "https://instagram.com/...",
#           twitter_url: "https://twitter.com/...",
#         ) %>
#
# Example 2 (override styles):
# <%= render Email::SocialIcons.new(
#           instagram_url: "https://instagram.com/...",
#           twitter_url: "https://twitter.com/...",
#           icon_size: "24px",
#           icons_spacing: "20px"
#           margin: "48px auto"
#         ) %>
#
class Email::SocialIcons < Email::Base
  def initialize(
    instagram_url: nil,
    facebook_url: nil,
    linkedin_url: nil,
    twitter_url: nil,
    x_url: nil,
    icon_size: "40px",
    icons_spacing: "5px",
    margin: "24px auto auto auto"
  )
    @icon_data = {
      instagram: {
        icon_url: "https://railsnotesui.xyz/img/icons/instagram-logo-black.png",
        link_url: instagram_url
      },
      facebook: {
        icon_url: "https://railsnotesui.xyz/img/icons/facebook-logo-black.png",
        link_url: facebook_url
      },
      linkedin: {
        icon_url: "https://railsnotesui.xyz/img/icons/linkedin-logo-black.png",
        link_url: linkedin_url
      },
      twitter: {
        icon_url: "https://railsnotesui.xyz/img/icons/twitter-logo-black.png",
        link_url: twitter_url
      },
      x: {
        icon_url: "https://railsnotesui.xyz/img/icons/x-logo-black.png",
        link_url: x_url
      }
    }

    @icon_size = icon_size
    @icons_spacing = icons_spacing
    @margin = margin
  end

  erb_template <<~ERB
      <table border="0" width="100%" align="center" cellpadding="0" cellspacing="0" style="width:100%; max-width:100%; margin: <%= @margin %>">
       <tbody>
          <tr>
             <td align="center" valign="top">
                <table border="0" width="100%" align="center" cellpadding="0" cellspacing="0" style="width:100%; max-width:100%;">
                   <tbody>
                      <tr>
                         <td align="center" valign="middle">
                            <% @icon_data.each do |name, values| %>
                             <% next if values[:link_url].nil? %>
                              <table border="0" align="center" cellpadding="0" cellspacing="0" style="display:inline-block; padding-right: <%= @icons_spacing %>">
                                <tbody>
                                    <tr>
                                      <td align="center" valign="middle" width="<%= @icon_size.delete('^0-9') %>">
                                          <a href=<%= values[:link_url] %> target="_blank" style="text-decoration:none;border:0">
                                           <img src=<%= values[:icon_url] %> alt="#" border="0" width="<%= @icon_size.delete('^0-9') %>" style="display:block;border:0;width:<%= @icon_size %>;">
                                          </a>
                                      </td>
                                    </tr>
                                </tbody>
                              </table>
                            <% end %>
                         </td>
                      </tr>
                   </tbody>
                </table>
             </td>
          </tr>
       </tbody>
    </table>
  ERB
end
