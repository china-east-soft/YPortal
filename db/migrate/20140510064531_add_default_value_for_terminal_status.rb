class AddDefaultValueForTerminalStatus < ActiveRecord::Migration
  def change
    change_column :terminals, :status, :integer, :default => 0
  end
end
