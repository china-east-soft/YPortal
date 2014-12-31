class ChangeDefaultValueToPrograms < ActiveRecord::Migration
  def up
    change_column :programs, :position, :integer, default: 0
  end

  def down
    change_column :programs, :position, :integer, default: nil
  end
end
