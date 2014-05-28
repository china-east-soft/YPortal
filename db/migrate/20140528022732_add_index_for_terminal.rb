class AddIndexForTerminal < ActiveRecord::Migration
  def change
    add_index :terminals, :mid
  end
end
