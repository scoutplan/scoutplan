# frozen_string_literal: true

class CandidateMessageRecipient
  attr_reader :member, :reason, :description

  delegate_missing_to :member
  def initialize(member, reason = :committed, description = nil)
    @member = member
    @reason = reason
    @description = description
  end
end
