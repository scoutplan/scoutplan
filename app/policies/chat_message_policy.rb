# frozen_string_literal: true

# Policy for manipulating chat messages
class ChatMessagePolicy < UnitContextPolicy
  def initialize(membership, chat_message)
    super
    @membership = membership
    @chat_message = chat_message
  end

  def index?
    true
  end

  def destroy?
    admin? || @chat_message.author == @membership
  end

  def edit?
    admin? || @chat_message.author == @membership
  end

  def update?
    admin? || @chat_message.author == @membership
  end

  def create?
    @membership.adult?
  end

  def impersonate?
    admin?
  end
end
