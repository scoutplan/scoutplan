# frozen_string_literal: true

# responsible for Unit <> User relationships
class UnitMembershipsController < ApplicationController
  before_action :find_unit, only: %i[index new create]
  before_action :find_membership, except: %i[index new create]

  def index
    authorize :unit_membership
    @unit_memberships = @unit.memberships.includes(:user)
    @page_title = t('members.index.page_title', unit_name: @unit.name)
    @membership = @unit.memberships.new
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
    @page_title = @user.full_name
    page_title [@unit.name, @user.full_name]
    build_new_relationship
  end

  def pundit_user
    @current_member
  end

  def new
    authorize :unit_membership
  end

  def invite
    respond_to :js
  end

  def send_message
    return unless (item = params[:item])

    case item
    when 'digest'
      MemberNotifier.send_digest(@target_membership)
    end
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
end
