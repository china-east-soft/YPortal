class AddEpgUpdatedAtToCities < ActiveRecord::Migration
  def change
    add_column :cities, :epg_created_at, :datetime
  end
end
