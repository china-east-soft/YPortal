class CreateMessageWarnings < ActiveRecord::Migration
  def change
    create_table :message_warnings do |t|
      t.string :mobile_number
      t.integer :warning_code
      t.text :message

      t.timestamps
    end
  end
end
