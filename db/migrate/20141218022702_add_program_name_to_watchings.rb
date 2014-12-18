class AddProgramNameToWatchings < ActiveRecord::Migration
  def change
    add_column :watchings, :program_name, :string
  end
end
