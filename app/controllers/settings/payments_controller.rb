# frozen_string_literal: true

require "stripe"

# controller for handling Stripe payment setup and management
module Settings
  class PaymentsController < UnitContextController
    def index
      authorize Payment
    end

    def onboard
      redirect_to unit_settings_path(current_unit) and return unless params[:unit][:auth] == "true"

      create_stripe_account
      redirect_to stripe_onboard_link, allow_other_host: true
    end

    def refresh
      # fetch_stripe_account
      redirect_to stripe_onboard_link, allow_other_host: true
    end

    def return_from_onboarding
    end

    private

    def create_stripe_account
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
      account = Stripe::Account.create(
        type: "express",
        country: "US",
        email: current_user.email,
        business_type: "non_profit",
        company: {
          name: current_unit.name
        }
      )

      PaymentAccount.create_with(account_id: account.id).find_or_create_by(unit: current_unit)

      # current_unit.payment_account.find_or_create_by(account_id: account.id)
    end

    def stripe_onboard_link
      Stripe::AccountLink.create({
        account: current_unit.payment_account.account_id,
        refresh_url: refresh_unit_payments_url,
        return_url: unit_settings_url(current_unit),
        type: "account_onboarding"
      })["url"]
    end

    def stripe_return_url
      return_from_onboarding_unit_payments_url(current_unit)
    end

    def stripe_refresh_url
      refresh_unit_payments_url(current_unit)
    end
  end
end