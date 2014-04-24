class CreateTerminal < ActiveRecord::Migration
  def change
    create_table :terminals do |t|
      t.string   "mac"
      t.string   "imei"
      t.string   "sim_iccid"
      t.integer  "status"
      t.integer  "merchant_id"
      t.string   "mid"
      t.timestamps
    end

    add_index :terminals, :mac
    
  end
end
