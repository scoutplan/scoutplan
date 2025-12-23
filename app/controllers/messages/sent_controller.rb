# frozen_string_literal: true

module Messages
  class SentController < UnitContextController
    include MessageListing

    def index
      authorize Message
      paginate_messages(base_message_scope.sent)
      render "messages/sent"
    end
  end
end
