# frozen_string_literal: true

# Controller for Units
class UnitsController < ApplicationController
  def index
    redirect_to root_path
  end

  def show
    @unit = Unit.find(params[:id])
    redirect_to unit_events_path(@unit)
  end
end
