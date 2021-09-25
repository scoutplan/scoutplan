# frozen_string_literal: true

# responsible for performing bulk user imports
class UnitMembershipsImportController < ApplicationController
  def new
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
    authorize :member_import, :create?
  end

  def create
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)

    return unless @current_member.admin?

    perform_import
  end

  def pundit_user
    @current_member
  end

  private

  def perform_import
    @new_memberships = []
    @existing_memberships = []

    file = params[:roster_file]
    data = SmarterCSV.process(file.tempfile)
    data.each do |row|
      email           = row[:email]&.downcase || "anonymous-member-#{SecureRandom.hex(6)}@scoutplan.org" unless email
      existing_user   = User.find_by(email: email)
      existing_member = @unit.membership_for(existing_user)

      if existing_user && existing_member
        @existing_memberships << existing_member
      elsif existing_user
        membership = @unit.memberships.create!(user: existing_user, status: :active, role: :member)
        @new_memberships << membership
      else
        generated_password = Devise.friendly_token.first(8)
        user = User.new(
          first_name: row[:first_name],
          last_name: row[:last_name],
          password: generated_password,
          password_confirmation: generated_password,
          email: email,
          type: :adult
        )
        user.save!

        membership = @unit.memberships.create!(user: user, status: :active, role: :member)
        @new_memberships << membership
      end
    end
  end
end
