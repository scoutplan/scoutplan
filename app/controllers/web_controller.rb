class WebController < ApplicationController
  skip_before_action :authenticate_user!
  layout "web"

  def index
    @unit = Unit.find(params[:unit_id])
  end
end
