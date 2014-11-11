class AddLogoToTelevisions < ActiveRecord::Migration
  def change
    add_attachment :televisions, :logo
  end
end
