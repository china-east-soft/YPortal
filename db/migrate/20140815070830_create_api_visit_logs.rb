class CreateApiVisitLogs < ActiveRecord::Migration
  def change
    create_table :api_visit_logs do |t|
      t.string   "request",         :limit => 2083
      t.text     "request_data"
      t.string   "remote_ip"
      t.integer  "response_status"
      t.text     "response"
      t.integer  "client_id"
      t.text     "debug"
      t.string   "api_version"
      t.string   "request_type"
      t.integer  "duration"
      t.boolean  "warned",                          :default => false
      t.timestamps
    end
  end
end
