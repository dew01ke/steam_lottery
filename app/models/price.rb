class Price < ActiveRecord::Base
  has_many :items
  validates :item_hash_name, presence: true
  validates :item_cost, presence: true
  validates :last_update, presence: true
end