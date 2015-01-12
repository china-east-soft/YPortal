class AddRemainWatchSecondsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remain_watch_seconds, :integer, default: 0
  end
end
