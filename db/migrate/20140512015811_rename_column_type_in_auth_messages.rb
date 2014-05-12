class RenameColumnTypeInAuthMessages < ActiveRecord::Migration
  def change
    rename_column :auth_messages, :type, :category
  end
end
