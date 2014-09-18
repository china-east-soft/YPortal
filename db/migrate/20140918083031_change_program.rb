class ChangeProgram < ActiveRecord::Migration
  def change
    rename_column :programs, :seq, :freq
  end
end
