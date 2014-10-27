class CreateAppConnections < ActiveRecord::Migration
  def change
    create_table :app_connections do |t|
      t.integer :app_id

      t.timestamps
    end
  end
end
