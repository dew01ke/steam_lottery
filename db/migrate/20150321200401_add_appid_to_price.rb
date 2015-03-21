class AddAppidToPrice < ActiveRecord::Migration
  def change
    change_table :prices do |t|
      t.integer :appid, :null => false
    end
  end
end
