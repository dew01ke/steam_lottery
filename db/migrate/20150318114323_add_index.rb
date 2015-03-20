class AddIndex < ActiveRecord::Migration
  def change
    add_index :items, :price_id
    add_index :active_raffles, :item_id
  end
end
