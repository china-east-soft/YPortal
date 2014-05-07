class CreateTerminal < ActiveRecord::Migration
  def change
    create_table :terminals do |t|
      t.integer  "agent_id"
      t.string   "mac"
      t.string   "imei"
      t.string   "sim_iccid"
      t.integer  "status"
      t.integer  "merchant_id"
      t.string   "mid"
      t.timestamps
    end

    add_index :terminals, :mac
    add_index :terminals, :merchant_id
    add_index :terminals, :agent_id
    
  end
end
