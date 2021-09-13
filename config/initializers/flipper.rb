class CanAccessFlipperUI
  def self.matches?(request)
    current_user = request.env['warden'].user
    current_user.present? && current_user.email == 'admin@scoutplan.org'
  end
end
