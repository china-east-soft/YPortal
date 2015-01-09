
set :environment, @environment
every 1.day, :at => '4:30 am' do
  rake "activites:update_activity_status"
  rake "data:clear_test_vtokens"
end

every 10.days, :at => '5 am' do
  rake "redis:clear_invalid_keys"
end

case @environment
when 'production'
  every 1.day, at: '02:00 am' do
    command "cd /root/ && backup perform --trigger protal_cloudchain_cn_files_backup"
    command "cd /root/ && backup perform --trigger protal_cloudchain_cn_database_backup"
  end
when 'testing'
  every 1.day, at: '02:00 am' do
    command "cd /root/ && backup perform --trigger protal_co_files_backup"
    command "cd /root/ && backup perform --trigger protal_co_database_backup"
  end
end

puts "debug:#{@environment}"

every 7.days, :at => '03:00 am' do
  rake "log:clear"
end

every 1.day, :at => '0:10 am' do
  rake "data:limit[api_visit_log, 5000]"
end

every :monday, :at => "5 am" do
  rake "epg:guide:generate"
end


# Learn more: http://github.com/javan/whenever
