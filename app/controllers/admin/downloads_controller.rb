# encoding: utf-8
class Admin::DownloadsController < AdminController

  set_tab :statistics
  set_tab :download, :sub_nav

  before_filter :setup, only: [:index]

  def index
    params[:download] ||= {}
    @downloads = Download
    @downloads = @downloads.by_app_name(params[:download][:app_name]) if params[:download][:app_name] and params[:download][:app_name] != 'all'
    @downloads = @downloads.before_date(params[:download][:end_date]) unless params[:download][:end_date].blank?
    @downloads = @downloads.after_date(params[:download][:start_date]) unless params[:download][:start_date].blank?
    params[:download][:date_part] = 'month' unless params[:download][:date_part]
    @downloads = @downloads.total_grouped_by(params[:download][:date_part])

    respond_to do |format|
      format.html {
        if @downloads.to_a.size > 0
          @line_chart_attrs = get_line_chart_attrs(@downloads)
          @pie_chart_attrs = get_pie_chart_attrs(@downloads)
        end
      }
      format.csv {
        send_data(csv_content_for(@downloads),
                  :type => "text/csv;charset=utf-8; header=present",
                  :filename => "下载统计_#{Time.now.strftime("%Y%m%d")}.csv")
      }
    end
  end

  private

  def setup
    @ways = ["统计", "下载统计"]
    # @left_panel = "layouts/statistics_left_panel"
  end

  def get_pie_chart_attrs(downloads)
    chart_attrs = {:type => 'pie'}
    chart_attrs[:title] = "iOS/Andriod 分布图"
    legends = Hash.new(0)
    downloads.all.each do |download|
      legends[app_display_name download.app_name] += download.total.to_i
    end
    from, to = case params[:download][:date_part]
    when 'year','day'
      [downloads.last.created_part, downloads.first.created_part]
    else
      ["#{downloads.last.created_year}-#{downloads.last.created_part}", "#{downloads.first.created_year}-#{downloads.first.created_part}#{date_parts[params[:download][:date_part]]}"]
    end
    title = "iOS/Andriod 版本分布图 (#{from.to_i} 到 #{to.to_i})"
    chart_attrs[:name] = title

    pie_total = legends.values.sum
    chart_attrs[:legends] = {}

    legends.each do |key, val|
      chart_attrs[:legends][key] = (val * 100.0/ pie_total).round(1)
    end

    chart_attrs
  end

  def get_line_chart_attrs(downloads)
    chart_attrs = {:type => 'line'}
    chart_attrs[:uom] = '次数'
    chart_attrs[:xaxis] = []
    chart_attrs[:title] = "APP下载 走势图"
    downloads.to_a.reverse.each do |download|
      if params[:download][:date_part] != 'year'
        chart_attrs[:xaxis] << [download.created_year,download.created_part] unless chart_attrs[:xaxis].include?([download.created_year,download.created_part])
      else
        chart_attrs[:xaxis] << download.created_year unless chart_attrs[:xaxis].include?(download.created_year)
      end
    end
    chart_attrs[:datas] = {"全部" => Array.new(chart_attrs[:xaxis].size){0}}
    downloads.to_a.reverse.each do |download|
      chart_attrs[:datas][app_display_name download.app_name] = Array.new(chart_attrs[:xaxis].size){0} unless chart_attrs[:datas][app_display_name download.app_name]
      xaxindex = if params[:download][:date_part] != 'year'
        chart_attrs[:xaxis].index([download.created_year,download.created_part])
      else
        chart_attrs[:xaxis].index(download.created_year)
      end
      chart_attrs[:datas][app_display_name download.app_name][xaxindex] = download.total
      chart_attrs[:datas]["全部"][xaxindex] += download.total.to_i
    end
    xaxis = chart_attrs[:xaxis]
    case params[:download][:date_part]
    when 'year'
      chart_attrs[:xaxis] = xaxis.collect{|xax| "#{xax}" }
    when 'day'
      chart_attrs[:xaxis] = xaxis.collect{|xax| "#{xax[1]}" }
    else
      chart_attrs[:xaxis] = xaxis.collect{|xax| "#{xax[0]}-#{xax[1]}" }
    end
    chart_attrs[:xaxis] = chart_attrs[:xaxis].last(20)
    chart_attrs[:datas].each do |key,value|
      chart_attrs[:datas][key] = value.last(20)
    end
    title = "APP下载 走势图 (#{chart_attrs[:xaxis].first.to_i} 到 #{chart_attrs[:xaxis].last.to_i})"
    title.insert -2, date_parts[params[:download][:date_part]] if !['day','year'].include?(params[:download][:date_part])
    chart_attrs[:name] = title
    chart_attrs
  end

  def csv_content_for(objs)
    CSV.generate do |csv|
      csv_th = ["\xEF\xBB\xBF客户端类型", "年", "次数"]
      csv_th.insert(2,date_parts[params[:download][:date_part]]) if params[:download][:date_part] != 'year'
      csv << csv_th

      if params[:download][:app_name] == 'all'
        objs.group_by{|download| [download.created_year,download.created_part] }.each do |created_attrs,downloads|
          csv_td = [
            "全部",
            created_attrs[0],
            downloads.sum{|i| i.total.to_i}
          ]
          csv_td.insert(2,created_attrs[1]) if params[:download][:date_part] != 'year'
          csv << csv_td
        end
      else
        objs.each do |record|
          csv_td = [
            (app_display_name record.app_name),
            record.created_year,
            record.total
          ]
          csv_td.insert(2,record.created_part) if params[:download][:date_part] != 'year'
          csv << csv_td
        end
      end
      csv
    end
  end

end

