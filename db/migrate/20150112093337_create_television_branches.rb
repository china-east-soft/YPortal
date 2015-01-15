class CreateTelevisionBranches < ActiveRecord::Migration
  def change
    create_table :television_branches do |t|
      t.string :name
      t.text :desc
      t.integer :position

      t.timestamps
    end
  end
end
