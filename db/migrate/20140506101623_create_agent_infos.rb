class CreateAgentInfos < ActiveRecord::Migration
  def change
    create_table :agent_infos do |t|
      t.integer :agent_id
      t.string :category
      t.string :name
      t.string :industry
      t.string :city
      t.string :contact
      t.string :telephone
      t.string :known_from
      t.string :remark
      t.integer :status, default: 0
      t.timestamps
    end

    add_index :agent_infos, :agent_id

  end
end
