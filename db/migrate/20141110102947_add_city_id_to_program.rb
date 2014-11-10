class AddCityIdToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :city_id, :integer
  end
end
