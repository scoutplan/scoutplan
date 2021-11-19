class UnitsController < ApplicationController
  def index
    redirect_to root_path
  end

  def show
    @unit = Unit.find(params[:id])
    respond_to do |format|
      format.css
    end
  end
end
