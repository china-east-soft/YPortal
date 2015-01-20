class AddDefaultValueToUsers < ActiveRecord::Migration
  def up
    change_column :users, :gender, :string, default: "male"
  end
  def down
    change_column :users, :gender, :string, default: nil
  end
end
