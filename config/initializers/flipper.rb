class CanAccessFlipperUI
  def self.matches?(request)
    current_user = request.env['warden'].user
    current_user.present? && (ENV['SCOUTPLAN_ADMINS']&.split(',') || ['admin@scoutplan.org']).include?(current_user.email)
  end
end
