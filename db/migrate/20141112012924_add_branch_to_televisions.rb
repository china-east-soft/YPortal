class AddBranchToTelevisions < ActiveRecord::Migration
  def change
    add_column :televisions, :branch, :integer, default: 0
  end
end
