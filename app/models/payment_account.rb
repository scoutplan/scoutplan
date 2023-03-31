# frozen_string_literal: true

# Purpose: To store the Stripe account information for a unit
class PaymentAccount < ApplicationRecord
  belongs_to :unit

  def active?
    account["charges_enabled"] && account["payouts_enabled"]
  end

  def account
    return @account if @account.present?

    Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
    @account = Stripe::Account.retrieve(unit.payment_account.account_id)
  end
end
