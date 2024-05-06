class SpreadsheetRowsController < ApplicationController
  def create
    @unit = Unit.find(params[:unit_id])
    @before = params[:before]
  end
end
