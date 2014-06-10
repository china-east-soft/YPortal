class DropAppAccount < ActiveRecord::Migration
  def change
    drop_table(:app_accounts)

    add_column :accounts, :email, :string,  null: true, default: ""
    add_column :accounts, :encrypted_password, :string, null: false, default: ""
    add_column :accounts, :reset_password_token, :string
    add_column :accounts, :reset_password_sent_at, :datetime
    ## Rememberable
    add_column :accounts, :remember_created_at, :datetime

    ## Trackable
    add_column :accounts, :sign_in_count, :integer, default: 0, null: false
    add_column :accounts, :current_sign_in_at, :datetime
    add_column :accounts, :last_sign_in_at, :datetime
    add_column :accounts, :current_sign_in_ip, :string
    add_column :accounts, :last_sign_in_ip, :string

    add_index :accounts, :mobile,                unique: true
    add_index :accounts, :reset_password_token, unique: true
  end
end
