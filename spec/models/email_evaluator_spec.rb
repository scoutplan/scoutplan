require "rails_helper"

RSpec.describe EmailEvaluator, type: :model do
  describe "methods" do
    describe "auto_responder?" do
      before do
        mail = Struct.new(:header, :from, :to).new
        header_value = Struct.new(:value).new("auto-replied")
        mail.header = { "Auto-Submitted" => header_value }
        mail.from = ["ozzy@blacksabbath.org"]
        mail.to = ["geezer@blacksabbath.org"]

        @inbound_email = Struct.new(:mail).new
        @inbound_email.mail = mail
        @email_evaluator = EmailEvaluator.new(@inbound_email)
      end

      it "returns false when Auto-Submitted header is not present" do
        @inbound_email.mail.header["Auto-Submitted"] = nil
      end

      it "returns true when Auto-Submitted header is auto-replied" do
        expect(@email_evaluator.auto_responder?).to be_truthy
      end

      it "returns true when Auto-Submitted header is auto-generated" do
        expect(@email_evaluator.auto_responder?).to be_truthy
      end
    end
  end
end
