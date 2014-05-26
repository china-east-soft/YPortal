class AddDurationForAuthTokens < ActiveRecord::Migration
  def change
    add_column :auth_tokens, :duration, :integer
  end
end
