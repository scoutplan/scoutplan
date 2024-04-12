# frozen_string_literal: true

class WebController < ActionController::Base
  layout "web"

  def index
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
    @slug = request.subdomain.split(".").first
    @unit = Unit.find_by(slug: @slug) if @slug.present?

    @slug = @unit.slug
    @partial_name = "#{@slug}_#{params[:path]}"
  end
end
