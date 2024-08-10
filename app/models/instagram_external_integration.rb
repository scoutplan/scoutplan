require "rest-client"

class InstagramExternalIntegration < ExternalIntegration
  BASE_GRAPH_URL = "https://graph.instagram.com".freeze

  def get_media
    url = "#{BASE_GRAPH_URL}/v11.0/#{identifier}/media?access_token=#{token}&fields=permalink,media_url,media_type"
    response = RestClient.get(url)
    json = JSON.parse(response.body)
    json["data"]
  end

  def refresh_access_token
    url = "#{BASE_GRAPH_URL}/refresh_access_token?grant_type=ig_refresh_token&access_token=#{token}"
    response = RestClient.get(url)
    return unless response["access_token"]

    update(token: response["access_token"], data: data.merge("expires_at" => Time.now + response["expires_in"]))
  end
end
