class DeposiedByToBigint < ActiveRecord::Migration
  def change
    change_column :items, :deposited_by, :bigint
  end
end
