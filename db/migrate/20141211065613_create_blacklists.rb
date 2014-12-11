class CreateBlacklists < ActiveRecord::Migration
  def change
    create_table :blacklists do |t|
      t.integer :blocker_id
      t.integer :blocked_id

      t.timestamps
    end

    add_index :blacklists, :blocker_id
    add_index :blacklists, :blocked_id
    add_index :blacklists, [:blocker_id, :blocked_id], unique: true
  end
end
