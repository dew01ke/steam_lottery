class AddDamnBigint < ActiveRecord::Migration
  def change
    change_column :short_finished_raffles, :winner_id, :bigint
    change_column :short_finished_raffles, :item_steam_id, :bigint
  end
end
