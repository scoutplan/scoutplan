# frozen_string_literal: true

# base Mailer
class ApplicationMailer < ActionMailer::Base
  default from: "info@scoutplan.org"
  layout "mailer"
  before_action :set_time_zone

  def set_time_zone
    Time.zone = "Eastern Time (US & Canada)"
  end
end
