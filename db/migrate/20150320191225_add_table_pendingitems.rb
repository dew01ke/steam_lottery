class AddTablePendingitems < ActiveRecord::Migration
  def change
    create_table :pending_items do |t|
      t.integer :item_steam_id, :null => false
      t.integer :price_id, :null => false
      t.integer :bot_id, :null => false
      t.integer :user_id, :null => false
    end
    change_column :pending_items, :item_steam_id, :bigint
    change_column :pending_items, :user_id, :bigint
  end
end
