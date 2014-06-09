class AddStatusToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :status, :integer, default: 0
  end
end
