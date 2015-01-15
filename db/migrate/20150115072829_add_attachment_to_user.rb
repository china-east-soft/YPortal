class AddAttachmentToUser < ActiveRecord::Migration
  def self.up
    add_attachment :users, :gravatar
    add_column :users, :avatar_type, :string
  end

  def self.down
    remove_attachment :users, :gravatar
    remove_column :users, :avatar_type
  end
end
