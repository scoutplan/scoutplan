class AutoResponderMailbox < ApplicationMailbox
  def process
    inbound_email.bounce!
  end
end
