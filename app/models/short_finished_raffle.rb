class ShortFinishedRaffle < ActiveRecord::Base
  validates :user_steamid, presence: true
  validates :item_name, presence: true
  validates :points_spent, presence: true
  validates :date, presence: true
end