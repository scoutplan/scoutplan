require "rest-client"

class InstagramExternalIntegration < ExternalIntegration
  include Rails.application.routes.url_helpers

  BASE_URL_AUTH_CODE = "https://api.instagram.com/oauth/authorize".freeze
  BASE_URL_GRAPH = "https://graph.instagram.com".freeze

  def media
    response = RestClient.get(media_url)
    json = JSON.parse(response.body)
    json["data"]
  end

  def auth_url
    "#{BASE_URL_AUTH_CODE}?client_id=#{ENV.fetch('INSTAGRAM_APP_ID')}&redirect_uri=#{redirect_uri}&scope=user_profile,user_media&response_type=code"
  end

  def redirect_uri
    url_for(controller: "instagram_external_integrations", action: "callback", only_path: false,
            host: ENV.fetch("APP_HOST"), protocol: :https)
  end

  def media_url
    "#{BASE_URL_GRAPH}/v11.0/#{identifier}/media?access_token=#{token}&fields=permalink,media_url,media_type"
  end

  def refresh_access_token
    url = "#{BASE_GRAPH_URL}/refresh_access_token?grant_type=ig_refresh_token&access_token=#{token}"
    response = RestClient.get(url)
    return unless response["access_token"]

    update(token: response["access_token"], data: data.merge("expires_at" => Time.now + response["expires_in"]))
  end
end
