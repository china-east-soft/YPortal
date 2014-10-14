class CreateBottomAds < ActiveRecord::Migration
  def change
    create_table :bottom_ads do |t|
      t.date :start_at
      t.date :end_at
      t.string :url

      t.timestamps
    end

    add_attachment :bottom_ads, :cover
  end
end
