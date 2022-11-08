# frozen_string_literal: true

# methods for displaying family information
class FamilyPresenter
  include ApplicationHelper

  def initialize(member)
    @member = member
    @family = @member.family(include_self: :prepend)
  end

  def active
    @family.select(&:status_active?)
  end

  def active_member_names
    active.map { |m| m.display_first_name(@member) }
  end

  def active_member_names_list
    list_of_words(active_member_names)
  end
end
