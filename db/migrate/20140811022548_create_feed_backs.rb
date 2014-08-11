class CreateFeedBacks < ActiveRecord::Migration
  def change
    create_table :feed_backs do |t|
      t.string :contact
      t.text :content

      t.string :phone_type
      t.string :client_version

      t.string :terminal_name
      t.string :terminal_version

      t.timestamps
    end
  end
end
