class AddHotToProducts < ActiveRecord::Migration
  def change
    #hot商品 1 是， 0否
    add_column :products, :hot, :integer, default: 0
  end
end
