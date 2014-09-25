class RenameColumnOfComments < ActiveRecord::Migration
  def change
    rename_column :comments, :type, :content_type
  end
end
