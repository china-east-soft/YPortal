class CreateTerminalVersions < ActiveRecord::Migration
  def change
    create_table :terminal_versions do |t|
      t.string   "name"
      t.string   "version"
      t.string   "size"
      t.string   "logo"
      t.text     "note"
      t.integer  "seq",              :default => 1
      t.string   "file_size"
      t.string   "support_versions"
      t.boolean  "release",          :default => false
      t.boolean  "enforce",          :default => false
      t.string   "branch"

      t.timestamps
    end
  end
end
