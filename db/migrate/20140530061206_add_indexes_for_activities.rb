class AddIndexesForActivities < ActiveRecord::Migration
  def change
    add_index :activities, :merchant_id
    add_index :activities, :status
    add_index :activities, :hot
  end
end
