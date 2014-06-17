class CreateAdvertises < ActiveRecord::Migration
  def change
    create_table :landings do |t|
      t.date :start_at
      t.date :end_at
      t.string :url
      t.timestamps
    end

    add_attachment :landings, :cover
  end
end
