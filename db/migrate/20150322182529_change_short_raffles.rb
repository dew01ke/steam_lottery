class ChangeShortRaffles < ActiveRecord::Migration
  def change
    change_table :short_finished_raffles do |t|
      t.integer :slots, :null => false
      t.integer :slot_price, :null => false
    end
    change_column :short_finished_raffles, :quality, :string
  end
end
