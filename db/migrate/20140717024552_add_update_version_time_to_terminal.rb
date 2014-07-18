class AddUpdateVersionTimeToTerminal < ActiveRecord::Migration
  def change
    add_column :terminals, :version_updated_at, :datetime
  end
end
