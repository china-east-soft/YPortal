class CreateTerminalVersion < ActiveRecord::Migration
  def change
    create_table :terminal_versions, force: true do |t|
      t.string   "name"
      t.string   "version"
      t.string   "size"
      t.string   "logo"
      t.string   "file"
      t.text     "note"
      t.text     "warning"
      t.integer  "seq",              :default => 1
      t.string   "file_size"
      t.string   "content_type"
      t.boolean  "release",          :default => false
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.boolean  "enforce",          :default => false
      t.string   "branch"
    end
  end
end
