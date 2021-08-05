class Event < ApplicationRecord
  belongs_to :unit
  validates_presence_of :title

  def past?
    starts_at.compare_with_coercion(Date.today) == -1
  end
end
