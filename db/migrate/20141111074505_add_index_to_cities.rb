class AddIndexToCities < ActiveRecord::Migration
  def change
    add_index :cities, :code
  end
end
