class RemoveColumnFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :email, :string
    remove_column :users, :birthdate, :date
    change_column :bots, :steam64, :bigint
  end
end
