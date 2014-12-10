class AddHuanxinRegistToUsers < ActiveRecord::Migration
  def change
    add_column :users, :register_huanxin, :boolean, default: false
    add_column :users, :username_huanxin, :string

    add_index  :users, :username_huanxin
  end

end
