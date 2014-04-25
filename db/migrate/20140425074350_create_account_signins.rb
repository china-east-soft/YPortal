class CreateAccountSignins < ActiveRecord::Migration
  def change
    create_table :account_signins do |t|
      t.integer :account_id
      t.integer :terminal_id
      t.datetime :created_at
    end

  end
end
