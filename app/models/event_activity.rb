class EventActivity < ApplicationRecord
  belongs_to :event
  validates_presence_of :event
  acts_as_list
end
