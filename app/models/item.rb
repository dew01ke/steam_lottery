class Item < ActiveRecord::Base
  validates :item_steam_id, presence: true
  validates :reference_id, presence: true
  validates :deposited_by, presence: true
  validates :deposited_on, presence: true
  validates :bot_id, presence: true
end