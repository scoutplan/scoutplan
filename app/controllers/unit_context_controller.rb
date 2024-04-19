# frozen_string_literal: true

class UnitContextController < ApplicationController
  prepend_before_action :set_unit_cookie
  prepend_before_action :capture_target_unit
  before_action :build_event_presenter
  before_action :set_paper_trail_whodunnit
  around_action :time_zone

  helper_method :current_member
  helper_method :current_unit

  def current_unit
    @current_unit ||= Unit.find(unit_id_param)
  end

  def current_member
    @current_member ||= current_unit.membership_for(current_user)
  end

  def pundit_user
    current_member
  end

  private

  def set_unit_cookie
    cookies[:current_unit_id] = { value: current_unit&.id }
    cookies[:current_member_id] = { value: current_member&.id }
  end

  def time_zone(&block)
    Time.use_zone(current_unit.time_zone, &block)
  end

  def unit_id_param
    params[:unit_id] || params[:id]
  end

  def user_for_paper_trail
    current_member&.id
  end

  def build_event_presenter
    @presenter = EventPresenter.new(nil, current_member)
  end

  def capture_target_unit
    cookies[:target_unit_id] = unit_id_param
  end
end
