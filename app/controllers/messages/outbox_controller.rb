# frozen_string_literal: true

module Messages
  class OutboxController < UnitContextController
    include MessageListing

    def index
      authorize Message
      paginate_messages(base_message_scope.outbox)
      render "messages/outbox"
    end
  end
end
