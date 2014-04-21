class AddNameAndTelephoneToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :category, :string
    add_column :agents, :name, :string
    add_column :agents, :industry, :string
    add_column :agents, :city, :string
    add_column :agents, :contact, :string
    add_column :agents, :telephone, :string
    add_column :agents, :known_from, :string
    add_column :agents, :remark, :string
    add_column :agents, :status, :integer, default: 0
  end
end
