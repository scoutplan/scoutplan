# frozen_string_literal: true

# relates a User to a Unit; serves as
# primary concept of a person in Scoutplan
class UnitMembership < ApplicationRecord
  include Flipper::Identifier
  include Contactable

  default_scope { includes(:user).order('users.first_name, users.last_name ASC') }

  belongs_to :unit
  belongs_to :user

  validates_uniqueness_of :user, scope: :unit
  validates_presence_of :user, :status

  has_many  :parent_relationships,
            foreign_key: 'child_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy

  has_many  :child_relationships,
            foreign_key: 'parent_unit_membership_id',
            class_name: 'MemberRelationship',
            dependent: :destroy

  has_many :rsvp_tokens, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :magic_links, dependent: :destroy

  alias_attribute :member, :user
  alias_attribute :rsvps, :event_rsvps

  enum status: { inactive: 0, active: 1 }, _prefix: true
  enum member_type: { unknown: 0, youth: 1, adult: 2 }

  delegate :full_name, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :display_first_name, to: :user
  delegate :full_display_name, to: :user
  delegate :short_display_name, to: :user
  delegate :nickname, to: :user
  delegate :email, to: :user
  delegate :phone, to: :user

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :child_relationships,
                                allow_destroy: true,
                                reject_if: ->(attributes) { attributes['child_unit_membership_id'].blank? }
  accepts_nested_attributes_for :parent_relationships, allow_destroy: true

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :communication, defaults: {
      via_email: true,
      via_sms: false
    }
  end

  def to_param
    "#{id}-#{full_display_name.parameterize}"
  end

  def admin?
    role == 'admin'
  end

  def parents
    parent_relationships.map(&:parent_member)
  end

  def children
    child_relationships.map(&:child_member)
  end

  def family
    (children | parents).append(self).sort_by(&:first_name)
  end

  def contactable_object
    user
  end

  def magic_link
    return unless unit.settings(:security).enable_magic_links
    return unless settings(:security).enable_magic_links

    magic_links.first || magic_links.create!
  end

  def time_zone
    user.settings(:locale).time_zone || unit.settings(:locale).time_zone || 'Eastern Time (US & Canada)'
  end
end
