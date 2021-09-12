# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@scoutplan.org'
  layout 'mailer'
end
