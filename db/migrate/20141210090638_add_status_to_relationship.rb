class AddStatusToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :status, :integer, default: 0
  end
end
