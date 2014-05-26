class AddDurationForTerminal < ActiveRecord::Migration
  def change
    add_column :terminals, :duration, :integer
  end
end
