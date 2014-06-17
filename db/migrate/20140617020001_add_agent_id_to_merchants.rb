class AddAgentIdToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :agent_id, :integer
  end
end
