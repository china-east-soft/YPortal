class AddTypeForAuthMessages < ActiveRecord::Migration
  def change
    add_column :auth_messages, :type, :integer, :default => 0
  end
end
