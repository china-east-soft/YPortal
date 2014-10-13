class AddDurationToComments < ActiveRecord::Migration
  def change
    add_column :comments, :duration, :integer
  end
end
