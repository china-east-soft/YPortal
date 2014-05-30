class AddColumsToProducts < ActiveRecord::Migration
  def change
    add_attachment :products, :product_photo
    add_column :products, :price, :decimal, :precision => 10, :scale => 8
    add_column :products, :description, :text
  end
end
