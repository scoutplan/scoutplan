class DiagnosticsController < ApplicationController
  layout "diagnostics"
  skip_before_action :authenticate_user!

  def index; end
end
