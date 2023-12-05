# frozen_string_literal: true

class UnitMembershipProfilePolicy < ApplicationPolicy
  attr_reader :user, :profile

  def initialize(user, profile)
    super
    @user = user
    @profile = profile
  end

  def edit?
    return true if profile.member.user == user && profile.member.adult?
    return true if profile.member.child_of?(user)

    false
  end

  def update?
    edit?
  end
end
