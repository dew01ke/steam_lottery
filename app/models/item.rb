class Item < ActiveRecord::Base
  belongs_to :price
  belongs_to :active_raffle
  validates :item_steam_id, presence: true
  validates :reference_id, presence: true
  validates :deposited_by, presence: true
  validates :deposited_on, presence: true
  validates :bot_id, presence: true
end