# frozen_string_literal: true

class WebController < ActionController::Base
  layout "web"

  # Custom domains pointed directly at this server. Each one must also be listed
  # in config/deploy.yml (proxy.hosts) and config.hosts in production.rb.
  CUSTOM_DOMAINS = {"new.troop2scarsdale.org" => "troop2scarsdale"}.freeze

  # Unit slug for a site request: a custom domain, or <slug>.sites.scoutplan.org
  def self.site_slug(request)
    CUSTOM_DOMAINS[request.host] || request.subdomain[/\A([^.]+)\.sites\b/, 1]
  end

  # rubocop:disable Metrics/AbcSize
  def index
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
    @slug = self.class.site_slug(request)
    @unit = Unit.find_by(slug: @slug) if @slug.present?
    head 404 and return unless @unit.present?

    @slug = @unit.slug
    @partial_name = "#{@slug}_#{params[:path]}"
    head 404 and return unless lookup_context.find_all("web/_#{@partial_name}").any?
  end
  # rubocop:enable Metrics/AbcSize
end
