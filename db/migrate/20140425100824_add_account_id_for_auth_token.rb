class AddAccountIdForAuthToken < ActiveRecord::Migration
  def change
    add_column :auth_tokens, :account_id, :integer
  end
end
