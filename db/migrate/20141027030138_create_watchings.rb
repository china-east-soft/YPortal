class CreateWatchings < ActiveRecord::Migration
  def change
    create_table :watchings do |t|
      t.integer :program_id
      t.datetime :started_at
      t.integer :seconds, default: 0

      t.timestamps
    end
  end
end
