class AddTerminalVersionIdToTerminal < ActiveRecord::Migration
  def change
    add_column :terminals, :terminal_version_id, :integer
  end
end
