class AddAddedByMerchantAtToTerminal < ActiveRecord::Migration
  def change
    add_column :terminals, :added_by_merchant_at, :datetime
  end
end
