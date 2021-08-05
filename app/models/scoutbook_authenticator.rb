class ScoutbookAuthenticator < ApplicationRecord
  def self.auth_url
    "https://scoutbook.scouting.org/default.asp?Source=&Redir="
  end

  def self.authenticate(username: nil, password: nil)
    return unless username && password
    Faraday.post(auth_url, "username=#{username}&password=#{password}")
  end
end
