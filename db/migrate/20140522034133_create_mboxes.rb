class CreateMboxes < ActiveRecord::Migration
  def change
    create_table :mboxes do |t|
      t.string :name
      t.integer :appid
      t.integer :portal_style_id
      t.string :category

      t.timestamps
    end

    add_index :mboxes, :appid
    add_index :mboxes, :portal_style_id
    add_attachment :mboxes, :cover

  end
end
