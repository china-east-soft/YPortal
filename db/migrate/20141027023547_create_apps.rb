class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :mac
      t.integer :app_version_id
      t.integer :app_connects_count, default: 0

      t.timestamps
    end
  end
end
