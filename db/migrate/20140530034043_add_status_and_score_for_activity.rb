class AddStatusAndScoreForActivity < ActiveRecord::Migration
  def change
    add_column :activities, :status, :integer
    add_column :activities, :score, :integer
    add_column :activities, :hit, :integer
  end
end
