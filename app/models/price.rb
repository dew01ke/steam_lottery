class Price < ActiveRecord::Base
  has_many :items
  has_many :short_finished_raffles
  has_many :stats
  validates :item_hash_name, presence: true
  validates :item_cost, presence: true
  validates :last_update, presence: true
end