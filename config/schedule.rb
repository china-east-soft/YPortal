# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

every 1.day, :at => '4:30 am' do
  rake "activites:update_activity_status"
  rake "data:clear_test_vtokens"
end

every 10.days, :at => '5 am' do
  rake "redis:clear_invalid_keys"
end

if @environment == 'production'
  every 1.day, at: '02:00 am' do
    command "cd /root/ && backup perform --trigger protal_cloudchain_cn_files_backup"
    command "cd /root/ && backup perform --trigger protal_cloudchain_cn_database_backup"
  end
elsif @environment == 'testing'
  every 1.day, at: '02:00 am' do
    command "cd /root/ && backup perform --trigger protal_co_files_backup"
    command "cd /root/ && backup perform --trigger protal_co_database_backup"
  end
end

every 7.days, :at => '03:00 am' do
  rake "log:clear"
end


# Learn more: http://github.com/javan/whenever
