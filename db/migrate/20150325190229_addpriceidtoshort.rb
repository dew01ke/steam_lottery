class Addpriceidtoshort < ActiveRecord::Migration
  def change
    change_table :short_finished_raffles do |t|
      t.remove :quality
      t.remove :item_name_rus
      t.remove :item_name_eng
      t.integer :price_id
    end
    add_column :short_finished_raffles, :started, 'timestamp '
    change_column :active_raffles, :created_at, 'timestamp '
    change_column :items, :created_at, 'timestamp '
    change_column :operations, :created_at, 'timestamp '
    change_column :prices, :last_update, 'timestamp '
    change_column :short_finished_raffles, :created_at, 'timestamp '
  end
end
