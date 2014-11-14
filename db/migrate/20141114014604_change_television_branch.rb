class ChangeTelevisionBranch < ActiveRecord::Migration
  def change
    remove_column :televisions, :branch
    add_column :televisions, :branch, :string
  end
end
