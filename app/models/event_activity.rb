class EventActivity < ApplicationRecord
  belongs_to :event
  validates_presence_of :event
end
