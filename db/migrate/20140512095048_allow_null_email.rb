class AllowNullEmail < ActiveRecord::Migration
  def up
    change_column :merchants, :email, :string, :null => true
    change_column :merchants, :mobile, :string, :null => false
    remove_index :merchants, :email
    add_index :merchants, :mobile,                unique: true
  end

  def down
    change_column :merchants, :email, :string, :null => false
    change_column :merchants, :mobile, :string, :null => true
    add_index :merchants, :email,                unique: true
    remove_index :merchants, :mobile
  end

end
