class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :mac
      t.string :channel
      t.string :body

      t.timestamps
    end
  end
end
