class AddColumsToProducts < ActiveRecord::Migration
  def change
    add_attachment :products, :product_photo
    add_column :products, :price, :decimal, :precision => 2, :scale => 10
    add_column :products, :description, :text
  end
end
