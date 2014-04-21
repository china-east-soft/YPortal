class AddNameAndAvatarToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :name, :string
    add_column :merchants, :industry, :string
    add_column :merchants, :province, :string
    add_column :merchants, :city, :string
    add_column :merchants, :area, :string
    add_column :merchants, :circle, :string
    add_column :merchants, :address, :string
    add_column :merchants, :contact, :string
    add_column :merchants, :mobile, :string
    add_column :merchants, :secondary, :string
  end
end
