class AddPicUrl < ActiveRecord::Migration
  def change
    add_column :prices, :image_url, :string
  end
end
