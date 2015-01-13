class AddEnableBranchToCities < ActiveRecord::Migration
  def change
    add_column :cities, :enable_branch, :bool, default: true
  end
end
