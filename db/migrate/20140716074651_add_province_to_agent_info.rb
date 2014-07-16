class AddProvinceToAgentInfo < ActiveRecord::Migration
  def change
    add_column :agent_infos, :province, :string
  end
end
