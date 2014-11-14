class AddProgramsCountToCities < ActiveRecord::Migration
  def change
    add_column :cities, :programs_count, :integer, default: 0
  end
end
