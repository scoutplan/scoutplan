class UnitsController < ApplicationController
  def show
    @unit = Unit.find(params[:id])
    respond_to do |format|
      format.css
    end
  end
end
