class Event < ApplicationRecord
  default_scope { order(starts_at: :asc) }

  belongs_to :unit
  belongs_to :series_parent, class_name: 'Event', optional: true
  belongs_to :event_category
  has_many   :series_children, class_name: 'Event'
  has_many   :event_rsvps, inverse_of: :event
  has_many   :users, through: :event_rsvps
  has_many   :rsvp_tokens

  has_rich_text :description

  alias_attribute :rsvps, :event_rsvps
  alias_attribute :category, :event_category

  accepts_nested_attributes_for :users

  validates_presence_of :title, :starts_at, :ends_at

  # TODO: change this. It's dumb. Let's just add a repeats_until attribute to
  # the Event model & be done with it
  after_create :create_series, if: Proc.new { self.respond_to? :repeats_until }

  enum status: { draft: 0, published: 1, cancelled: 2 }

  def past?
    starts_at.past?
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
end
