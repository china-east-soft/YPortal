class CreatePointRules < ActiveRecord::Migration
  def change
    create_table :point_rules do |t|
      t.string :name
      t.text :desc
      t.integer :credit

      t.timestamps
    end
  end
end
