class ChangeProgramChannel < ActiveRecord::Migration
  def change
    change_column :programs, :channel, :string, null: true
  end
end
