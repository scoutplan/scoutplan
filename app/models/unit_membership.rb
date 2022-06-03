# frozen_string_literal: true

# A join model between Units and Users. In fact, the bulk of the
# business logic in the app is based on a UnitMembership rather than
# a User. The User model is really more for authentication and
# basic user demographic information (e.g. DOB) that's unlikely to change
# from one Unit to another
#
class UnitMembership < ApplicationRecord
  include Flipper::Identifier
  include Contactable

  default_scope { includes(:user).order("users.first_name, users.last_name ASC") }

  belongs_to :unit
  belongs_to :user

  validates_uniqueness_of :user, scope: :unit
  validates_presence_of :user, :status

  has_many  :parent_relationships,
            foreign_key: "child_unit_membership_id",
            class_name: "MemberRelationship",
            dependent: :destroy

  has_many  :child_relationships,
            foreign_key: "parent_unit_membership_id",
            class_name: "MemberRelationship",
            dependent: :destroy

  has_many :rsvp_tokens, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :magic_links, dependent: :destroy
  has_many :messages, foreign_key: :author_id
  has_many :visits, class_name: "Ahoy::Visit"
  has_many :event_organizers

  alias_attribute :member, :user
  alias_attribute :rsvps, :event_rsvps

  enum status: { inactive: 0, active: 1, registered: 2 }, _prefix: true
  enum role: { member: "member", admin: "admin", event_organizer: "event_organizer" }
  enum member_type: { unknown: 0, youth: 1, adult: 2 }

  scope :status_active_and_registered, -> { where(status: %i[active registered]) } # everyone except inactives
  scope :contactable, -> { includes(:user).where("email NOT LIKE 'anonymous-member-%@scoutplan.org'") }

  delegate :time_zone, to: :unit
  delegate :name, to: :unit, prefix: :unit
  delegate_missing_to :user

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :child_relationships,
                                allow_destroy: true,
                                reject_if: ->(attributes) { attributes["child_unit_membership_id"].blank? }
  accepts_nested_attributes_for :parent_relationships, allow_destroy: true

  has_settings do |s|
    s.key :security, defaults: { enable_magic_links: true }
    s.key :communication, defaults: {
      via_email: true,
      via_sms: false
    }
  end

  def to_param
    [id, user&.full_display_name].join("-").parameterize
  end

  def admin?
    role == "admin"
  end

  def parents
    parent_relationships.map(&:parent_member)
  end

  def children
    child_relationships.map(&:child_member)
  end

  def family(include_self: true)
    res = (children | parents)
    res.append(self) if include_self
    res.sort_by(&:first_name)
  end

  def contactable_object
    user
  end

  def time_zone
    user.settings(:locale).time_zone || unit.settings(:locale).time_zone || "Eastern Time (US & Canada)"
  end
end
