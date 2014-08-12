class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.string   "remote_ip"
      t.datetime "created_at",     :null => false
      t.integer  "app_version_id"
    end

    add_index "downloads", ["app_version_id"], :name => "index_downloads_on_app_id"
  end
end
