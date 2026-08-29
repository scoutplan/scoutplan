# frozen_string_literal: true

# Rails main froze the default `default_url_options` hash (`{}.freeze` in
# ActionDispatch::Routing::UrlFor) as part of its Ractor-shareability work, but
# released rspec-rails (6.1.5 here; 8.0.4 too) still mutates it in place:
#
#   default_url_options[:host] ||= DEFAULT_HOST                 # feature specs
#   options.each { |k, v| default_url_options[k] = v }          # mailer specs
#
# so every `type: :feature` and `type: :mailer` spec dies at load time with
# `FrozenError: can't modify frozen Hash: {}`.
#
# rspec-rails main fixed both in commit 9fb6f4f0, "Assign default_url_options
# instead of mutating it", which is unreleased. This backports that commit by
# swapping the two Concerns' `included` blocks. Both patches are guarded on
# DEFAULT_OPTIONS, the constant that same commit introduced, so they drop out on
# their own once we're on an rspec-rails that carries the fix.
unless RSpec::Rails::FeatureExampleGroup.const_defined?(:DEFAULT_OPTIONS)
  RSpec::Rails::FeatureExampleGroup.instance_variable_set(:@_included_block, proc {
    app = ::Rails.application
    if app.respond_to?(:routes)
      include app.routes.url_helpers     if app.routes.respond_to?(:url_helpers)
      include app.routes.mounted_helpers if app.routes.respond_to?(:mounted_helpers)

      if respond_to?(:default_url_options)
        self.default_url_options =
          {host: ::RSpec::Rails::FeatureExampleGroup::DEFAULT_HOST}.merge(default_url_options)
      end
    end
  })

  if defined?(RSpec::Rails::MailerExampleGroup) && defined?(ActionMailer)
    RSpec::Rails::MailerExampleGroup.instance_variable_set(:@_included_block, proc {
      include ::Rails.application.routes.url_helpers
      options = ::Rails.configuration.action_mailer.default_url_options
      self.default_url_options = default_url_options.merge(options) if options.present?
    })
  end
end

# Same story in view specs: Rails main now freezes the memoized `_prefixes`
# array (ActionView::ViewPaths::ClassMethods#_prefixes), and rspec-rails' view
# example group appends to it in place:
#
#   view.lookup_context.prefixes << _controller_path
#
# giving `FrozenError: can't modify frozen Array: ["", "action_view/test_case/test"]`.
# Config-level `before` hooks run ahead of the example group's own, so handing
# the lookup context a private copy first makes that append legal. It also stops
# the controller path from accumulating on the shared array across examples,
# which is what the in-place append used to do.
RSpec.configure do |config|
  config.before(:each, type: :view) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.dup
  end
end
