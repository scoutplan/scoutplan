class ApplicationMailbox < ActionMailbox::Base
  routing /.*@/i => :forwards
end
