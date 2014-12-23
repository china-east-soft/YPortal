class AddPositionToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :position, :integer
  end
end
