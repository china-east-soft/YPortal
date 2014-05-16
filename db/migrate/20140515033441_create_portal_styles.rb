class CreatePortalStyles < ActiveRecord::Migration
  def change
    create_table :portal_styles do |t|
      t.integer :merchant_id
      t.string :name
      t.string :btn_style

      t.timestamps
    end
  end
end
