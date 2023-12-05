# frozen_string_literal: true

# a person in Scoutplan. Most business logic, however
# is handled in the UnitMembership class
class User < ApplicationRecord
  include Flipper::Identifier
  include Contactable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  phony_normalize :phone, default_country_code: "US"

  has_many  :unit_memberships, dependent: :destroy
  has_many  :units, through: :unit_memberships
  has_many  :events, through: :units
  has_many  :parent_relationships,
            foreign_key: "child_unit_membership_id",
            class_name: "MemberRelationship",
            dependent: :destroy
  has_many  :child_relationships,
            foreign_key: "parent_unit_membership_id",
            class_name: "MemberRelationship",
            dependent: :destroy

  before_validation :check_email
  before_validation :check_password

  validates_presence_of :first_name, :last_name

  alias_attribute :display_name, :full_display_name

  self.inheritance_column = nil
  enum type: { unknown: 0, youth: 1, adult: 2 }

  has_settings do |s|
    s.key :locale, defaults: { time_zone: "Eastern Time (US & Canada)" }
    s.key :communication, defaults: { intro_sms_sent: false }
  end

  def contactable_object
    self
  end

  def self.from_omniauth(auth)
    where(email: auth.info.email).first
  end

  def family
    unit_memberships.map(&:family).flatten.uniq
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def display_first_name(user = nil)
    return "You" if user == self

    # nickname.blank? ? first_name : nickname
    nickname.presence || first_name
  end

  def full_display_name
    "#{display_first_name} #{last_name}"
  end

  def short_display_name(period: true)
    "#{display_first_name} #{last_name&.first}#{period ? '.' : ''}"
  end

  def multiple_units?
    units.count > 1
  end

  def smsable?
    phone.present?
  end

  def check_email
    return if email.present?

    self.email = User.generate_anonymous_email
  end

  def self.generate_anonymous_email
    "anonymous-member-#{SecureRandom.hex(6)}@scoutplan.org"
  end

  def check_password
    return if encrypted_password.present?

    generated_password = Devise.friendly_token.first(8)
    self.password = generated_password
    self.password_confirmation = generated_password
  end

  def super_admin?
    (ENV["SCOUTPLAN_ADMINS"]&.split(",") || ["admin@scoutplan.org"]).include?(email)
  end

  def email_address_with_name
    ActionMailer::Base.email_address_with_name(email, display_name)
  end
end
