class ActiveRaffle < ActiveRecord::Base
  has_one :item
  validates :item_pool_id, presence: true
  validates :icon_url, presence: true
  validates :item_name, presence: true
  validates :item_value, presence: true
  validates :num_slots, presence: true
  validates :slot_value, presence: true
end