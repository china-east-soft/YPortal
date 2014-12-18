class AddPointsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :points, :integer, default: 0
    add_column :users, :experience, :integer, default: 0
  end
end
