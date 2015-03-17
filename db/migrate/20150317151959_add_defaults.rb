class AddDefaults < ActiveRecord::Migration
  def change
    change_column_default :users, :exp, 0
    change_column_default :users, :points, 0
    change_column_default :prices, :item_cost, 10000
    change_column_default :items, :deposited_by, 0
    change_column_null :operations, :item_name, true
    rename_column :short_finished_raffles, :date, :created_at
    rename_column :operations, :date, :created_at
    rename_column :items, :deposited_on, :created_at
    rename_column :active_raffles, :started, :created_at
  end
end
