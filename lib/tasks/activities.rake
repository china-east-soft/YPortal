namespace :activites do
  
  desc 'update status for activity'
  task :update_activity_status => :environment do
    activities = Activity.where(["started_at <= ? and end_at >= ?", Date.today, Date.today]).where(status: Activity.statuses[:init])
    activities.update_all(status: Activity.statuses[:active])

    activities = Activity.where(["end_at < ?", Date.today]).where(status: Activity.statuses[:active])
    activities.update_all(status: Activity.statuses[:expired])
  end

end