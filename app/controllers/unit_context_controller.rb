# frozen_string_literal: true

# an abstract controller to be subclassed for instances
# where a Unit is being manipulated (which is to say, most)
class UnitContextController < ApplicationController
  before_action :find_unit_info
  before_action :set_unit_cookie
  around_action :time_zone
  after_action  :track_action

  def current_unit
    @current_unit || (@current_unit = Unit.includes(
      :setting_objects,
      unit_memberships: [:user, :parent_relationships, :child_relationships]
    ).find(params[:unit_id] || params[:id]))
  end

  def current_member
    @current_member || (@current_member = current_unit.membership_for(current_user))
  end

  attr_reader :current_membership

  def pundit_user
    @membership
  end

  protected

  def track_action
    ahoy.track "Ran action", request.path_parameters
  end

  private

  def find_unit_info
    return unless params[:unit_id].present? || params[:id].present?

    # TODO: scope this to the current user's memberships
    @current_unit = @unit = Unit.includes(:unit_memberships).find(params[:unit_id] || params[:id])
    @current_member = @membership = @unit.membership_for(current_user)
    Time.zone = @unit.settings(:locale).time_zone
  end

  def set_unit_cookie
    cookies[:current_unit_id] = { value: current_unit&.id }
  end

  def time_zone(&block)
    Time.use_zone(current_unit.time_zone, &block)
  end
end
