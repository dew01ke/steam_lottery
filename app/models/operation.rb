class Operation < ActiveRecord::Base
  validates :user_steamid, presence: true
  validates :date, presence: true
  validates :item_name, presence: true
  validates :amount, presence: true
end