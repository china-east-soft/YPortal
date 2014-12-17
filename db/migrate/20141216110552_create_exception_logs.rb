class CreateExceptionLogs < ActiveRecord::Migration
  def change
    create_table :exception_logs do |t|
      t.string :title
      t.text :body
      t.boolean :solved, default: false

      t.timestamps
    end
  end
end
