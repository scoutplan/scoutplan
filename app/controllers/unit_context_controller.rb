# frozen_string_literal: true

# an abstract controller to be subclassed for instances
# where a Unit is being manipulated (which is to say, most)
class UnitContextController < ApplicationController
  before_action :find_unit_info, only: %i[index new create edit]
  before_action :set_unit_cookie
  before_action :track_activity

  # invoke Mixpanel tracker
  def track_activity
    tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
    track_member(tracker)
    event = [controller_name, action_name].join("#")
    tracker.track(@current_member.id, event)
  end

  def track_member(tracker)
    tracker.people.set(
      current_member.id,
      {
        "$first_name" => current_member.first_name,
        "$last_name" => current_member.last_name,
        "$email" => current_member.email,
        "$unit" => [ @current_member.unit.name, @current_member.unit.location].join(" ")
      }
    )
  end

  def current_unit
    @current_unit || (@current_unit = Unit.includes(
      :setting_objects,
      unit_memberships: [:user, :parent_relationships, :child_relationships]
    ).find(params[:unit_id]))
  end

  def current_member
    @current_member || (@current_member = current_unit.membership_for(current_user))
  end

  attr_reader :current_membership

  def pundit_user
    @membership
  end

  private

  def find_unit_info
    return unless params[:unit_id].present?

    # TODO: scope this to the current user's memberships
    @current_unit = @unit = Unit.includes(:unit_memberships).find(params[:unit_id])
    @current_member = @membership = @unit.membership_for(current_user)
    Time.zone = @unit.settings(:locale).time_zone
  end

  def set_unit_cookie
    cookies[:current_unit_id] = { value: current_unit&.id }
  end
end
