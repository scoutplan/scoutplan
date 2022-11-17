class PackingList < ApplicationRecord
  belongs_to :unit
  has_many :packing_list_items, dependent: :destroy
end
