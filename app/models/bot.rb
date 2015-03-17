class Bot < ActiveRecord::Base
  validates :steam64, presence: true
  validates :steamlogin, presence: true
end