class Admin::CheckInsController < AdminController

  def index
    params[:check_in] ||= {}

    @raw_check_ins = AuthToken

    if params[:check_in][:terminal].present? && params[:check_in][:terminal] != 'all'
      @raw_check_ins = @raw_check_ins.by_terminal(params[:check_in][:terminal])
    end

    @raw_check_ins = @raw_check_ins.before_date(params[:check_in][:end_date]) unless params[:check_in][:end_date].blank?
    @raw_check_ins = @raw_check_ins.after_date(params[:check_in][:start_date]) unless params[:check_in][:start_date].blank?
    params[:check_in][:date_part] = 'month' unless params[:check_in][:date_part]
    @check_ins = @raw_check_ins.total_grouped_by(params[:check_in][:date_part])

    respond_to do |format|
      format.html {
        if @check_ins.to_a.present?
          @line_chart_attrs = get_signin_line_chart_attrs(@check_ins)
        end
      }

      format.csv {
        send_data(csv_content_for(@account_signins),
                  :type => "text/csv;charset=utf-8; header=present",
                  :filename => "下载统计_#{Time.now.strftime("%Y%m%d")}.csv")
      }
    end
  end


  private
  def date_range
    @start_date = nil
    @end_date = nil

    if params[:check_in][:start_date].blank? && params[:check_in][:end_date].blank?
      case params[:check_in][:date_part]
      when 'day'
        @start_date = 14.days.ago(Date.today)
        @end_date = Date.today
        @range = (@end_date - @start_date).to_i
      when 'week'
        @start_date = 14.weeks.ago(Date.today.beginning_of_week)
        @end_date = Date.today
        @range = (@end_date.cwyear - @start_date.cwyear) * 52 + @end_date.cweek - @start_date.cweek
      when 'month'
        @start_date = 14.months.ago(Date.today.beginning_of_month)
        @end_date = Date.today
        @range = (@end_date.year - @start_date.year) * 12 + @end_date.month - @start_date.month
      when 'year'
        @start_date = 14.years.ago(Date.today.beginning_of_year)
        @end_date = Date.today
        @range = @end_date.year - @start_date.year
      end
    elsif !params[:check_in][:start_date].blank? && params[:check_in][:end_date].blank?
      @start_date = params[:check_in][:start_date].to_date
      case params[:check_in][:date_part]
      when 'day'
        if 15.days.since(@start_date) > Date.today
          @end_date = Date.today
        else
          @end_date = 15.days.since(@start_date)
        end
        @range = (@end_date - @start_date).to_i
      when 'week'
        if 15.weeks.since(@start_date) > Date.today
          @end_date = Date.today
        else
          @end_date = 15.weeks.since(@start_date)
        end
        @range = (@end_date.cwyear - @start_date.cwyear) * 52 + @end_date.cweek - @start_date.cweek
      when 'month'
        if 15.months.since(@start_date) > Date.today
          @end_date = Date.today
        else
          @end_date = 15.months.since(@start_date)
        end
        @range = (@end_date.year - @start_date.year) * 12 + @end_date.month - @start_date.month
      when 'year'
        if 15.years.since(@start_date) > Date.today
          @end_date = Date.today
        else
          @end_date = 15.years.since(@start_date)
        end
        @range = @end_date.year - @start_date.year
      end
    elsif params[:check_in][:start_date].blank? && !params[:check_in][:end_date].blank?
      @end_date = params[:check_in][:end_date].to_date
      case params[:check_in][:date_part]
      when 'day'
        @start_date = 15.days.ago(@end_date)
        @range = (@end_date - @end_date).to_i
      when 'week'
        @start_date = 15.weeks.ago(@end_date)
        @range = (@end_date.cwyear - @start_date.cwyear) * 52 + @end_date.cweek - @start_date.cweek
      when 'month'
        @start_date = 15.months.ago(@end_date)
        @range = (@end_date.year - @start_date.year) * 12 + @end_date.month - @start_date.month
      when 'year'
        @start_date = 15.years.ago(@end_date)
        @range = @end_date.year - @start_date.year
      end
    else
      @start_date = params[:check_in][:start_date].to_date
      @end_date = params[:check_in][:end_date].to_date
      if @end_date > Date.today
        @end_date = Date.today
      end
      case params[:check_in][:date_part]
      when 'day'
        if 15.days.since(@start_date) < @end_date
          @end_date = 15.days.since(@start_date)
        end
        @range = (@end_date - @start_date).to_i
      when 'week'
        if 15.weeks.since(@start_date) < @end_date
          @end_date = 15.weeks.since(@start_date)
        end
        @range = (@end_date.cwyear - @start_date.cwyear) * 52 + @end_date.cweek - @start_date.cweek
      when 'month'
        if 15.months.since(@start_date) < @end_date
          @end_date = 15.months.since(@start_date)
        end
        @range = (@end_date.year - @start_date.year) * 12 + @end_date.month - @start_date.month
      when 'year'
        if 15.years.since(@start_date) < @end_date
          @end_date = 15.years.since(@start_date)
        end
        @range = @end_date.year - @start_date.year
      end
    end
    @range = @range + 1
  end

  def get_signin_line_chart_attrs(check_ins)
    date_range

    chart_attrs = {:type => 'line'}
    chart_attrs[:title] = "签到记录(#{date_parts[params[:check_in][:date_part]]})"
    chart_attrs[:name] = "签到记录(#{date_parts[params[:check_in][:date_part]]})"
    chart_attrs[:min_width] = 530
    chart_attrs[:uom] = ''
    chart_attrs[:xaxis] = []
    case params[:check_in][:date_part]
    when 'day'
      (@start_date..@end_date).each do |iday|
        chart_attrs[:xaxis] << iday
      end
      check_ins = check_ins.where(["auth_tokens.created_at >= ? and auth_tokens.created_at <= ?",@start_date,1.days.since(@end_date)])
      check_ins = check_ins.group("DATE(auth_tokens.created_at)")
      chart_attrs[:datas] = {"签到记录" => Array.new(@range){0}}
      check_ins.select("DATE(auth_tokens.created_at) as created_part,count(auth_tokens.id) as total").each do |acg|
        chart_attrs[:datas]["签到记录"][chart_attrs[:xaxis].index(Date.parse(acg.created_part))] = acg.total
      end
    when 'week'
      t_month = @start_date
      while (t_month.cwyear < @end_date.cwyear) or (t_month.cwyear == @end_date.cwyear && t_month.cweek <= @end_date.cweek) do
        chart_attrs[:xaxis] << [t_month.cwyear,t_month.cweek].join("-")
        t_month = t_month.next_week
      end
      check_ins = check_ins.where(["auth_tokens.created_at >= ? and auth_tokens.created_at <= ?",@start_date,1.days.since(@end_date)])
      check_ins = check_ins.group("EXTRACT(ISOYEAR from auth_tokens.created_at),EXTRACT(week from auth_tokens.created_at)")
      chart_attrs[:datas] = {"签到记录" => Array.new(@range){0}}
      check_ins.select("EXTRACT(ISOYEAR from auth_tokens.created_at) as created_year,EXTRACT(week from auth_tokens.created_at) as created_part,count(auth_tokens.id) as total").each do |acg|
        chart_attrs[:datas]["签到记录"][chart_attrs[:xaxis].index("#{acg.created_year.to_i}-#{acg.created_part.to_i}")] = acg.total
      end
    when 'month'
      t_month = @start_date
      while t_month.strftime("%Y-%m") <= @end_date.strftime("%Y-%m") do
        chart_attrs[:xaxis] << t_month.strftime("%Y-%m").to_s
        t_month = t_month.next_month
      end
      check_ins = check_ins.where(["auth_tokens.created_at >= ? and auth_tokens.created_at <= ?",@start_date,1.days.since(@end_date)])
      check_ins = check_ins.group("EXTRACT(YEAR from auth_tokens.created_at),EXTRACT(MONTH from auth_tokens.created_at)")
      chart_attrs[:datas] = {"签到记录" => Array.new(@range){0}}
      check_ins.select("EXTRACT(YEAR from auth_tokens.created_at) as created_year,EXTRACT(MONTH from auth_tokens.created_at) as created_part,count(auth_tokens.id) as total").each do |acg|
        logger.info([acg.created_year.to_i,acg.created_part.to_i,acg.total].join(" "))
        chart_attrs[:datas]["签到记录"][chart_attrs[:xaxis].index(Date.new(acg.created_year.to_i,acg.created_part.to_i).strftime("%Y-%m"))] = acg.total
      end
    when 'year'
      t_month = @start_date
      while t_month.strftime("%Y") <= @end_date.strftime("%Y") do
        chart_attrs[:xaxis] << t_month.strftime("%Y").to_s
        t_month = t_month.next_year
      end
      check_ins = check_ins.where(["auth_tokens.created_at >= ? and auth_tokens.created_at <= ?",@start_date,1.days.since(@end_date)])
      check_ins = check_ins.group("EXTRACT(YEAR from auth_tokens.created_at),EXTRACT(MONTH from auth_tokens.created_at)")
      chart_attrs[:datas] = {"签到记录" => Array.new(@range){0}}
      check_ins.select("EXTRACT(YEAR from auth_tokens.created_at) as created_part,count(auth_tokens.id) as total").each do |acg|
        chart_attrs[:datas]["签到记录"][chart_attrs[:xaxis].index(Date.new(acg.created_part.to_i).strftime("%Y"))] = acg.total
      end
    end
    chart_attrs
  end

  def csv_content_for(objs)
    CSV.generate do |csv|
      csv_th = ["\xEF\xBB\xBF终端组", "年", "次数"]
      csv_th.insert(2,date_parts[params[:check_in][:date_part]]) if params[:check_in][:date_part] != 'year'
      csv << csv_th

      if params[:check_in][:group_name] == 'all'
        objs.group_by{|check_in| [check_in.created_year,check_in.created_part] }.each do |created_attrs,check_ins|
          csv_td = [
            "全部",
            created_attrs[0],
            check_ins.sum{|i| i.total.to_i}
          ]
          csv_td.insert(2,created_attrs[1]) if params[:check_in][:date_part] != 'year'
          csv << csv_td
        end
      else
        objs.each do |record|
          csv_td = [
            (record.terminal_id.present? ? Terminal.where(id: record.terminal_id).first.try(:terminal_group).try(:group_name) : ""),
            record.created_year,
            record.total
          ]
          csv_td.insert(2,record.created_part) if params[:check_in][:date_part] != 'year'
          csv << csv_td
        end
      end
      csv
    end
  end
end
