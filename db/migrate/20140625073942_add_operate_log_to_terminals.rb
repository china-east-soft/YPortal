class AddOperateLogToTerminals < ActiveRecord::Migration
  def change
    add_column :terminals, :operate_log, :text
  end
end
