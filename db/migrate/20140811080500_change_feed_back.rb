class ChangeFeedBack < ActiveRecord::Migration
  def change
    rename_column :feed_backs, :terminal_name, :terminal_version_name
    add_column :feed_backs, :client_mac, :string
    add_column :feed_backs, :terminal_mac, :string
  end
end
