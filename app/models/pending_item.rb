class PendingItem < ActiveRecord::Base
  belongs_to :price
  validates :item_steam_id, presence: true
  validates :price_id, presence: true
  validates :bot_id, presence: true
  validates :user_id, presence: true
end