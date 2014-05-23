class AddStatusForMbox < ActiveRecord::Migration
  def change
    add_column :mboxes, :status, :integer, default: 1
  end
end
