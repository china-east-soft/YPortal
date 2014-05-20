class AddDescriptionAndUrlForBanners < ActiveRecord::Migration
  def change
    add_column :banners, :description, :string
    add_column :banners, :url, :string
  end
end
