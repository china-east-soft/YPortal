class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :merchant_id
      t.string :title
      t.date :started_at
      t.date :end_at
      t.text :description
      t.boolean :hot

      t.timestamps
    end

    add_attachment :activities, :cover
  end
end
