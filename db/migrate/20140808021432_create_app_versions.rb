class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
      t.string   "name"
      t.string   "size"
      t.string   "logo"
      t.string   "file"
      t.text     "note"
      t.integer  "seq",              :default => 1
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.string   "file_size"
      t.string   "content_type"
      t.string   "itunes_url"
      t.boolean  "release",          :default => false
      t.string   "version"
      t.boolean  "enforce",          :default => false
      t.string   "branch"
    end
  end
end
