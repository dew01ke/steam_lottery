class ChangeShortRaffled < ActiveRecord::Migration
  def change
    change_table :short_finished_raffles do |t|
      t.remove :user_steamid
      t.remove :points_spent
      t.remove :item_name
      t.integer :item_steam_id, :null => false
      t.integer :winner_id, :null => false
      t.integer :quality, :null => false
      t.string :item_name_rus, :null => false
      t.string :item_name_eng, :null => false
      t.text :slot_info, :null => false
    end
  end
end
