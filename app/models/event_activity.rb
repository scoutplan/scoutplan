class EventActivity < ApplicationRecord
  belongs_to :event, touch: true
  validates_presence_of :event
  validates_presence_of :title
  acts_as_list
end
