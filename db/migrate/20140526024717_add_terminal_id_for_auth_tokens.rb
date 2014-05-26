class AddTerminalIdForAuthTokens < ActiveRecord::Migration
  def change
    add_column :auth_tokens, :terminal_id, :integer
    add_column :auth_tokens, :merchant_id, :integer

    add_index :auth_tokens, :terminal_id
    add_index :auth_tokens, :merchant_id

  end

end
