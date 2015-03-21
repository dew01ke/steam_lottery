class AddNamesToPrices < ActiveRecord::Migration
  def change
    change_table :prices do |t|
      t.string :display_name_rus, :null => false
      t.string :display_name_eng, :null => false
    end
  end
end
