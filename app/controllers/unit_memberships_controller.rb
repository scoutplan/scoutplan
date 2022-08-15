# frozen_string_literal: true

# responsible for Unit <> User relationships
class UnitMembershipsController < ApplicationController
  before_action :find_unit, only: %i[index new create bulk_update invite]
  before_action :find_membership, except: %i[index new create bulk_update]

  def index
    authorize UnitMembership
    @unit_memberships = @unit.memberships.includes(
      :user,
      { parent_relationships: { parent_unit_membership: :user } },
      { child_relationships: { child_unit_membership: :user } }
    ).order("users.first_name, users.last_name ASC")
    @page_title = @unit.name, t("members.titles.index", unit_name: "")
    @membership = @unit.memberships.build
    @membership.build_user
  end

  def edit
    build_new_relationship
  end

  def new
    @target_membership = @unit.memberships.build(role: "member")
    @target_membership.build_user
    build_new_relationship
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
    @page_title = @user.full_name
    @rsvp_events = @unit.events.published.future.rsvp_required
    page_title [@unit.name, @user.full_display_name]
  end

  def create
    find_or_create_user

    @member = @unit.memberships.new(member_params)
    @member.user_id = @user.id
    return unless @member.save!

    flash[:notice] = t("members.confirmations.create", member_name: @member.full_display_name, unit_name: @unit.name)
    redirect_to unit_members_path(@unit)
  end

  def find_or_create_user
    @user = User.create_with(
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      nickname: user_params[:nickname],
      phone: user_params[:phone]
    ).find_or_create_by!(email: user_params[:email])
  end

  def update
    @target_membership.assign_attributes(member_params)
    update_settings_params
    return unless @target_membership.save!

    flash[:notice] = "Member information updated"
    redirect_to unit_members_path(@current_unit)
  end

  def invite
    authorize @target_membership
    @target_membership.user.invite!(current_user)
    redirect_to unit_member_path(@unit, @target_membership), notice: "Invitation sent"
  end

  def update_settings_params
    return unless settings_params

    settings_params.each do |setting_key, values|
      values.each do |subsetting_key, subsetting_value|
        @target_membership.settings(setting_key.to_sym).assign_attributes subsetting_key.to_sym => subsetting_value
      end
    end
  end

  def pundit_user
    @current_member
  end

  # POST /bulk_update
  # when Events index was in bulk mode
  def bulk_update
    member_params = params.require(:member).permit(:status, :member_type)
    params[:members].each do |member_id|
      member = UnitMembership.find(member_id)
      member.assign_attributes(member_params)
      member.save!
    end

    flash[:notice] = t("members.bulk_update.success_message")
    redirect_to unit_members_path(@unit)
  end

  private

  def build_new_relationship
    # @target_membership.child_relationships.build
    @member_relationship = MemberRelationship.new(parent_member: @target_membership)

    # possible relationships are any other unit members, minus onesself, minus existing child memberships
    @candidates = @current_unit.memberships -
                  [@target_membership] -
                  @target_membership.child_relationships.collect(&:child_member)
  end

  def find_membership
    @target_membership = UnitMembership.includes(:parent_relationships, :child_relationships).find(params[:id] || params[:member_id])
    @target_user = @target_membership.user
    @current_unit = @unit = @target_membership.unit
    @current_member = @unit.membership_for(current_user)
  end

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
  end

  def member_params
    params.require(:unit_membership).permit(
      :status, :role, :member_type,
      child_relationships_attributes: [:id, :child_unit_membership_id, :_destroy],
      parent_relationships_attributes: [:id, :_destroy],
      user_attributes: [:first_name, :last_name, :phone]
    )
  end

  def user_params
    params.require(:unit_membership).permit(
      user_attributes: [:id, :first_name, :nickname, :last_name, :email, :phone]
    )[:user_attributes]
  end

  def settings_params
    params.require(:settings).permit(
      communication: [:via_email, :via_sms]
    )
  end
end
