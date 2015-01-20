class AddDefaultValueToUsers < ActiveRecord::Migration
  def up
    change_column :users, :gender, :string, default: "male"
    change_column :users, :name, :string, default: "游客"
  end
  def down
    change_column :users, :gender, :string, default: nil
    change_column :users, :name, :string, default: nil
  end
end
