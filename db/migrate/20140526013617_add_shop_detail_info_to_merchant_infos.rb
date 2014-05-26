class AddShopDetailInfoToMerchantInfos < ActiveRecord::Migration
  def change
    add_attachment :merchant_infos, :shop_photo
    add_column :merchant_infos, :shop_description, :text
    add_column :merchant_infos, :shop_phone_one, :string
    add_column :merchant_infos, :shop_phone_two, :string
    add_column :merchant_infos, :shop_longitude, :decimal, {:precision=>10, :scale=>6}
    add_column :merchant_infos, :shop_latitude, :decimal, {:precision=>10, :scale=>6}
  end
end
