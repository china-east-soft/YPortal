class ChangeMerchangInfos < ActiveRecord::Migration
  def change
    rename_column :merchant_infos, :contact, :contact_person_name
    add_column :merchant_infos, :contact_way, :string
  end
end
