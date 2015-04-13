class Addquality < ActiveRecord::Migration
  def change
    add_column :prices, :wear, :integer
  end
end
