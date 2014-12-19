class CreateUserCheckIns < ActiveRecord::Migration
  def change
    create_table :user_check_ins do |t|
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
