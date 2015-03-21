class AddQualityToPrices < ActiveRecord::Migration
  def change
    change_table :prices do |t|
      t.integer :quality, :null => false
    end
  end
end
