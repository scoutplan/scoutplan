# frozen_string_literal: true

class AutoResponderMailbox < ApplicationMailbox
  def process
    # quietly ignore auto-responder emails
  end
end
