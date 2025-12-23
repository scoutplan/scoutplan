# frozen_string_literal: true

module MessageListing
  extend ActiveSupport::Concern

  private

  def base_message_scope
    current_unit.messages
                .includes(message_recipients: [unit_membership: :user])
                .with_attached_attachments
                .order(updated_at: :desc)
  end

  def paginate_messages(scope)
    set_page_and_extract_portion_from(scope.all, per_page: [20])
  end
end
