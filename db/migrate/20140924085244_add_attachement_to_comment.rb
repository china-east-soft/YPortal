class AddAttachementToComment < ActiveRecord::Migration
  def change
    add_column :comments, :type, :string, default: "text"

    add_attachment :comments, :audio
  end
end
