class AddProgramIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :program_id, :integer
  end
end
