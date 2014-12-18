class CreatePotinDetails < ActiveRecord::Migration
  def change
    create_table :potin_details do |t|
      t.belongs_to :user, index: true
      t.belongs_to :point_rule, index: true

      t.timestamps
    end
  end
end
