class AddBranchToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :branch, :string
  end
end
