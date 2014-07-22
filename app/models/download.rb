# encoding: utf-8

class Download < ExternalTable
  default_scope { where("app_version_id is not null") }

  belongs_to :app_version

  scope :by_app_name, lambda {|name| joins(:app_version).where(["app_versions.name = ?", name])}
  scope :before_date, lambda {|date| where(["downloads.created_at < ?", 1.days.since(Time.zone.parse(date)).strftime("%Y-%m-%d")])}
  scope :after_date, lambda {|date| where(["downloads.created_at >= ?", date])}

  def self.total_grouped_by(date_part)
    case date_part
    when 'day'
      downloads = self.joins(:app_version).group("EXTRACT(YEAR from downloads.created_at),DATE(downloads.created_at),app_versions.name")
      downloads = downloads.order("max(EXTRACT(YEAR from downloads.created_at)) desc,max(DATE(downloads.created_at)) desc,max(app_versions.name)")
      downloads = downloads.select("EXTRACT(YEAR from downloads.created_at) as created_year,DATE(downloads.created_at) as created_part, app_versions.name as app_name, count(downloads.id) as total")
    when 'week'
      downloads = self.joins(:app_version).group("EXTRACT(ISOYEAR from downloads.created_at),EXTRACT(#{date_part} from downloads.created_at),app_versions.name")
      downloads = downloads.order("max(EXTRACT(ISOYEAR from downloads.created_at)) desc,max(EXTRACT(#{date_part} from downloads.created_at)) desc,max(app_versions.name)")
      downloads = downloads.select("EXTRACT(ISOYEAR from downloads.created_at) as created_year,EXTRACT(#{date_part} from downloads.created_at) as created_part, app_versions.name as app_name, count(downloads.id) as total")
    when 'month','year'
      downloads = self.joins(:app_version).group("EXTRACT(YEAR from downloads.created_at),EXTRACT(#{date_part} from downloads.created_at),app_versions.name")
      downloads = downloads.order("max(EXTRACT(YEAR from downloads.created_at)) desc,max(EXTRACT(#{date_part} from downloads.created_at)) desc,max(app_versions.name)")
      downloads = downloads.select("EXTRACT(YEAR from downloads.created_at) as created_year,EXTRACT(#{date_part} from downloads.created_at) as created_part, app_versions.name as app_name, count(downloads.id) as total")
    end
  end

end
