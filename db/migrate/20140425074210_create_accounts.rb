class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :mobile
      t.string :type
      t.string :uuid
      t.integer :count_of_signins
      t.timestamps
    end
  end
end
