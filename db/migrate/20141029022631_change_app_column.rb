class ChangeAppColumn < ActiveRecord::Migration
  def change
    rename_column :apps, :app_connects_count, :app_connections_count
  end
end
