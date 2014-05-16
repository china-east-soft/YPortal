class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.integer :portal_style_id
    end

    add_attachment :banners, :cover
    
  end
end
