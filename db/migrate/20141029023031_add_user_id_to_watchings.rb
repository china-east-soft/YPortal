class AddUserIdToWatchings < ActiveRecord::Migration
  def change
    add_column :watchings, :user_id, :integer
  end
end
