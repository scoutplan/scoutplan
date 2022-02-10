# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to unit_events_path(current_user.unit_memberships.first.unit)
  end
end
