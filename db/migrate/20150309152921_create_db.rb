class CreateDb < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :steamid, :null => false
      t.string :email
      t.date :birthdate
      t.integer :exp
      t.integer :points
      t.boolean :banned, :default => false
    end

    create_table :active_raffles do |t|
      t.integer :item_pool_id, :null => false
      t.string :icon_url, :null => false
      t.string :item_name, :null => false
      t.integer :item_value, :null => false
      t.integer :num_slots, :null => false
      t.integer :slot_value, :null => false
      t.datetime :started, :null => false
      t.boolean :is_finished, :null => false, :default => false
    end

    create_table :short_finished_raffles do |t|
      t.integer :user_steamid, :null => false
      t.string :item_name, :null => false
      t.integer :points_spent, :null => false
      t.datetime :date, :null => false
    end

    create_table :operations do |t|
      t.integer :user_steamid, :null => false
      t.datetime :date, :null => false
      t.boolean :is_deposit, :null => false, :default => false
      t.boolean :is_item, :null => false, :default => false
      t.string :item_name, :null => false
      t.integer :amount, :null => false, :default => 0
    end

    create_table :items do |t|
      t.integer :item_steam_id, :null => false
      t.integer :reference_id, :null => false
      t.integer :deposited_by, :null => false
      t.datetime :deposited_on, :null => false
      t.integer :bot_id, :null => false
    end

    create_table :prices do |t|
      t.string :item_hash_name, :null => false
      t.integer :item_cost, :null => false, :default => 0
      t.datetime :last_update, :null => false
    end
    change_column :items, :item_steam_id, :bigint
    change_column :operations, :user_steamid, :bigint
    change_column :short_finished_raffles, :user_steamid, :bigint
    change_column :users, :steamid, :bigint
  end
end
