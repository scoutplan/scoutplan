# frozen_string_literal: true

class WebController < ActionController::Base
  layout "web"

  # rubocop:disable Metrics/AbcSize
  def index
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
    @slug = request.subdomain.split(".").first
    @unit = Unit.find_by(slug: @slug) if @slug.present?
    head 404 and return unless @unit.present?

    @slug = @unit.slug
    @partial_name = "#{@slug}_#{params[:path]}"
    head 404 and return unless lookup_context.find_all("web/_#{@partial_name}").any?
  end
  # rubocop:enable Metrics/AbcSize
end
