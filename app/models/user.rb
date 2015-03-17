class User < ActiveRecord::Base
  validates :steam64, presence: true
  validates :exp, presence: true
  validates :points, presence: true

end