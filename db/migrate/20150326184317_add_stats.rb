class AddStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :price_id, :null => false
      t.time :total_time, :null => false
      t.datetime :finished, :null => false, :default => 0
    end
  end
end
