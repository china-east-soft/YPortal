class AddProgramIdToUser < ActiveRecord::Migration
  def change
    add_reference :users, :program, index: true
  end
end
