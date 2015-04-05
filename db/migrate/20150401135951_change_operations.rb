class ChangeOperations < ActiveRecord::Migration
  def change
    change_table :operations do |t|
      t.remove :is_deposit
      t.remove :is_item
    end
    rename_column :operations, :item_name, :info
    add_column :operations, :type, :integer
  end
end
