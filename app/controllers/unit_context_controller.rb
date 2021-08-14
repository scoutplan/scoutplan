class UnitContextController < ApplicationController
  def current_unit
    Unit.first
  end
end
