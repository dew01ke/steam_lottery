class Test < ActiveRecord::Migration
  def change
    change_column_default :active_raffles, :created_at, 0
    change_column_default :items, :created_at, 0
    change_column_default :operations, :created_at, 0
    change_column_default :prices, :last_update, 0
    change_column_default :short_finished_raffles, :created_at, 0
    change_column_default :short_finished_raffles, :started, 0
  end
end
