class CreateTelevisions < ActiveRecord::Migration
  def change
    create_table :televisions do |t|
      t.string :name

      t.timestamps
    end
  end
end
