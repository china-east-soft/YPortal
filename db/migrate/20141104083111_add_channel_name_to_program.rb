class AddChannelNameToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :channel_name, :string
  end
end
