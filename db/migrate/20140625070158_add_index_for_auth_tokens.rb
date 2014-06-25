class AddIndexForAuthTokens < ActiveRecord::Migration
  def change
    add_index :auth_tokens, :status
    add_index :auth_tokens, :mac
    add_index :auth_tokens, [:status, :mac, :client_identifier]
  end
end
