class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :channel,  null: false

      t.string :mode
      t.integer :seq
      t.integer :sid
      t.string :location

      t.string :name
      t.integer :comments_count, default: 0

      t.timestamps
    end
    add_index :programs, :channel, unique: true
  end
end
