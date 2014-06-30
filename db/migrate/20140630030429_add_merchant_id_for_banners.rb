class AddMerchantIdForBanners < ActiveRecord::Migration
  def change
    add_column :banners, :merchant_id, :integer
    add_index :banners, :merchant_id
    Banner.all.each do |banner|
      banner.update_column(:merchant_id, PortalStyle.where(id: banner.portal_style_id).first.merchant_id) if banner.portal_style_id
    end
    remove_column :banners, :portal_style_id
  end
end
