class CreateAuthMessages < ActiveRecord::Migration
  def change
    create_table :auth_messages do |t|
      t.string :mobile
      t.string :verify_code
      t.datetime :activated_at
      t.datetime :created_at
    end

    add_index :auth_messages, :mobile
  end
end
