class CreateAuthToken < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.string :auth_token
      t.integer :expired_timestamp
      t.string :mac
      t.string :client_identifier
      t.integer :status
      t.string :mid
      t.timestamps
    end

    add_index :auth_tokens, :auth_token

  end
end
