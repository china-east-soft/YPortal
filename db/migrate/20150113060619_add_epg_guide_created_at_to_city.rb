class AddEpgGuideCreatedAtToCity < ActiveRecord::Migration
  def change
    add_column :cities, :epg_guide_created_at, :datetime
  end
end
