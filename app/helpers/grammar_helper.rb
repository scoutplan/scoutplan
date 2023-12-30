# frozen_string_literal: true

module GrammarHelper
  def member_list(members, current_member, conjunction = "and")
    members.map do |member|
      if member == current_member
        "you"
      else
        member.first_name
      end
    end.to_grammatical_list(conjunction: conjunction)
  end
end
