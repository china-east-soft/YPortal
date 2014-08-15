class ApiVisitLog < ActiveRecord::Base
  scope :after_date, lambda {|date| where(["created_at >= ?", date])}
  scope :before_date, lambda {|date| where(["created_at < ?", 1.days.since(Time.zone.parse(date)).strftime("%Y-%m-%d")])}
end
