class AddBigIntToOperations < ActiveRecord::Migration
  def change
    change_column :operations, :user_steamid, :bigint
  end
end
