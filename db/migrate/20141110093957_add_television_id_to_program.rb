class AddTelevisionIdToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :television_id, :integer
  end
end
