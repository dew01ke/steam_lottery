class AddLastToToken < ActiveRecord::Migration
  def change
    add_column :users, :last_to_token, :string
  end
end
