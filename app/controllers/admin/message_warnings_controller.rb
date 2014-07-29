class Admin::MessageWarningsController < AdminController
  set_tab :statistics

  def index
    if params[:message_warning].nil? || params[:message_warning].empty?
      params[:message_warning] = {}
    end

    @message_warnings = MessageWarning.order('created_at DESC')

    if params[:message_warning][:mobile_number].present?
      @message_warnings = @message_warnings.where(mobile_number: params[:message_warning][:mobile_number])
    end

    if params[:message_warning][:warning_code] and params[:message_warning][:warning_code] != 'all'
      @message_warnings = @message_warnings.by_warning_code(params[:message_warning][:warning_code])
    end

    if params[:message_warning][:end_date].present?
      @message_warnings = @message_warnings.before_date(params[:message_warning][:end_date])
    end

    if params[:message_warning][:start_date].present?
      @message_warnings = @message_warnings.after_date(params[:message_warning][:start_date])
    end

    respond_to do |format|
      format.html {
        if @message_warnings.all.size > 0
          @chart_attrs = get_pie_chart_attrs(@message_warnings)
        end
        @message_warnings = @message_warnings.page params[:page]
      }
      format.csv {
        @message_warnings = @message_warnings.all
        send_data(csv_content_for(@message_warnings),
                  :type => "text/csv;charset=utf-8; header=present",
                  :filename => "短信统计_#{Time.now.strftime("%Y%m%d")}.csv")
      }
    end
  end

  def get_pie_chart_attrs(message_warnings)
    chart_attrs = {type: 'pie', title: '短信分布',name: '短信分布'}

    legends = Hash.new(0)
    message_warnings.each do |message_warning|
      legends[message_warning.display_name] += 1
    end
    chart_attrs[:legends] = legends
    chart_attrs
  end

  def csv_content_for(objs)
    CSV.generate do |csv|
      csv << ["\xEF\xBB\xBF手机","代码", "信息", "创建时间"]
      objs.each do |record|
        csv << [
          record.mobile_number,
          record.warning_code,
          record.display_name,
          record.created_at.in_time_zone("Beijing").to_s[0..-6]
        ]
      end
    end
  end
end
