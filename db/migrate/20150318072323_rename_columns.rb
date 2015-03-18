class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :items, :reference_id, :price_id
    rename_column :active_raffles, :item_pool_id, :item_id
  end
end
