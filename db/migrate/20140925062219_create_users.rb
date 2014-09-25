class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :mobile_number
      t.string :avatar
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :mobile_number, unique: true
  end
end
