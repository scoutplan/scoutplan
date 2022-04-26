# frozen_string_literal: true

# Controller for Units
class UnitsController < UnitContextController
  def show
    redirect_to unit_events_path(@unit)
  end
end
