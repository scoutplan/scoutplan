# frozen_string_literal: true

# a person in Scoutplan. Most business logic, however
# is handled in the UnitMembership class
class User < ApplicationRecord
  include Flipper::Identifier
  include Contactable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :unit_memberships, dependent: :destroy
  has_many  :parent_relationships,
            foreign_key: 'child_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy
  has_many  :child_relationships,
            foreign_key: 'parent_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy

  before_validation :check_email

  self.inheritance_column = nil
  enum type: { unknown: 0, youth: 1, adult: 2 }

  has_settings do |s|
    s.key :locale, defaults: { time_zone: 'Eastern Time (US & Canada)' }
    s.key :security, defaults: { enable_magic_links: true }
  end

  def contactable_object
    self
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def display_first_name
    nickname.blank? ? first_name : nickname
  end

  def full_display_name
    "#{display_first_name} #{last_name}"
  end

  def short_display_name
    "#{display_first_name} #{last_name.first}."
  end

  def display_legal_and_nicknames
    res = [first_name]
    res << "(#{ nickname})" unless nickname.blank?
    res << last_name
    res.join(' ')
  end

  def check_email
    return if email.present?

    self.email = User.generate_anonymous_email
  end

  def self.generate_anonymous_email
    "anonymous-member-#{SecureRandom.hex(6)}@scoutplan.org"
  end
end
