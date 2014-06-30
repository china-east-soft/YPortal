class AddLayoutForPortalStyles < ActiveRecord::Migration
  def change
    add_column :portal_styles, :layout, :string
    add_column :portal_styles, :current, :boolean
  end
end
