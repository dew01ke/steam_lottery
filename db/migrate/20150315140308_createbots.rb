class Createbots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.integer :steam64, :null => false
      t.string :steamlogin, :null => false
      t.string :password
      t.string :last_sessionid
      t.string :token
      t.string :token_secure
      t.string :webcookie
      t.string :user_agent
    end

    change_table :users do |t|
      t.rename :steamid, :steam64
    end
  end
end
