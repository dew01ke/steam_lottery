class AddapikeyToBots < ActiveRecord::Migration
  def change
    add_column :bots, :api_key, :string
    add_column :users, :access_type, :integer
  end
end
