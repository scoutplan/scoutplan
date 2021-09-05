class Event < ApplicationRecord
  belongs_to :unit
  belongs_to :series_parent, class_name: 'Event', optional: true
  belongs_to :event_category
  has_many   :series_children, class_name: 'Event'
  has_many   :event_rsvps
  has_many   :rsvp_tokens
  alias_attribute :rsvps, :event_rsvps
  validates_presence_of :title, :starts_at, :ends_at
  default_scope { order(starts_at: :asc) }
  alias_attribute :category, :event_category
  after_create :create_series, if: Proc.new { self.respond_to? :repeats_until }
  after_create :create_magic_links, if: :requires_rsvp
  enum status: { draft: 0, published: 1 }

  def past?
    starts_at.compare_with_coercion(Date.today) == -1
  end

  def rsvp_open?
    requires_rsvp && starts_at > DateTime.now
  end

  def has_rsvp_for?(user)
    event_rsvps.count > 0
  end

  def series?
    !new_record? && (series_children.count > 0 || series_siblings.count > 0)
  end

  def series_children
    Event.where(series_parent_id: id)
  end

  def series_siblings
    return [] unless series_parent_id.present?
    Event.where(series_parent_id: series_parent_id)
  end

  def rsvp_token_for(user)
    self.rsvp_tokens.find_by(user: user)
  end

private

  # create a weekly series based on @event
  def create_series
    new_event = self.dup
    new_event.series_parent = self

    # TODO: this is hokey...let's just add a repeats_until attribute on the model
    while new_event.starts_at < self.repeats_until
      new_event.starts_at += 7.days
      new_event.ends_at += 7.days
      new_event.save!
      new_event = new_event.dup
    end
  end

  # for events where RSVP is wanted, generate an RSVP token for each active member
  def create_magic_links
    self.unit.memberships.active.each { |membership| RsvpToken.create(user: membership.user, event: self) }
  end
end
