class CreateMerchantInfos < ActiveRecord::Migration
  def change
    create_table :merchant_infos do |t|
      t.integer :merchant_id
      t.string :name
      t.string :industry
      t.string :province
      t.string :city
      t.string :area
      t.string :circle
      t.string :address
      t.string :contact
      t.string :secondary
      t.timestamps
    end

    add_index :merchant_infos, :merchant_id

  end
end
