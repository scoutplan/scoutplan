require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "new_user_email" do
    it "sends" do
      @code = "123456"
      @email = "ozzy@blacksabbath.org"
      mail = UserMailer.with(code: @code, email: @email).new_user_email
      expect(mail.subject).to eq("Scoutplan verification code: #{@code}")
    end
  end
end
