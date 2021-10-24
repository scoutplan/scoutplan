# frozen_string_literal: true

# responsible for Unit <> User relationships
class UnitMembershipsController < ApplicationController
  before_action :find_unit, only: %i[index new create bulk_update]
  before_action :find_membership, except: %i[index new create bulk_update]

  def index
    authorize UnitMembership
    @unit_memberships = @unit.memberships.includes(:user)
    @page_title = @unit.name, t('members.index.page_title')
    @membership = @unit.memberships.build
    @membership.build_user
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
    @page_title = @user.full_name
    page_title [@unit.name, @user.display_full_name]
    build_new_relationship
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    @member = @unit.memberships.new(member_params)
    @member.status = :active
    @member.user.password = @member.user.password_confirmation = generated_password
    return unless @member.save!

    flash[:notice] = 'Member Added'
    redirect_to unit_members_path(@unit)
  end

  def pundit_user
    @current_member
  end

  def send_message
    return unless (item = params[:item])

    case item
    when 'digest'
      @message_name = 'Digest'
      MemberNotifier.send_digest(@target_membership)
    when 'daily_reminder'
      @message_name = 'Daily Reminder'
      MemberNotifier.send_daily_reminder(@target_membership)
    end
  end

  def bulk_update
    member_params = params.require(:member).permit(:status, :member_type)
    params[:members].each do |member_id|
      member = UnitMembership.find(member_id)
      member.assign_attributes(member_params)
      member.save!
    end

    flash[:notice] = t('members.bulk_update.success_message')
    redirect_to unit_members_path(@unit)
  end

  private

  def build_new_relationship
    @member_relationship = MemberRelationship.new(parent_member: @target_membership)

    # possible relationships are any other unit members, minus onesself, minus existing child memberships
    @candidates = @current_unit.memberships -
                  [@target_membership] -
                  @target_membership.child_relationships.collect(&:child_member)
  end

  def find_membership
    @target_membership = UnitMembership.find(params[:id])
    @target_user = @target_membership.user
    @current_unit = @unit = @target_membership.unit
    @current_member = @unit.membership_for(current_user)
  end

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
  end

  def member_params
    params.require(:unit_membership).permit(:status, :role, :member_type,
      user_attributes: [:first_name, :nickname, :last_name, :email, :phone]
    )
  end
end
