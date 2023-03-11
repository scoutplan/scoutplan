# frozen_string_literal: true

# Service for creating new Units
class NewUnitService
  attr_accessor :unit, :user

  def initialize(user)
    @user = user
  end

  def create(unit_name, location)
    @unit_name = unit_name
    @location = location

    return unless @user
    return unless create_unit

    create_membership
    @unit
  end

  #-------------------------------------------------------------------------
  private

  def create_unit
    @unit = Unit.new(name: @unit_name, location: @location, email: email_username)
    return @unit if @unit.save

    false
  end

  def create_membership
    @member = @unit.memberships.new(user: @user, role: :admin, status: :active, member_type: :adult)
    return @member if @member.save

    false
  end

  def email_username
    base = "#{@unit_name.parameterize}#{@location.parameterize}".gsub("-", "")
    candidate = base
    candidate = "#{base}#{rand(100)}" while Unit.exists?(email: candidate)
    candidate
  end

  # place a limit on the number of units a member can create
  def user_can_create_unit?
    member.unit_memberships.admin.count < 3
  end
end
