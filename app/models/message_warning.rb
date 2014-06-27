class MessageWarning < ActiveRecord::Base
  MSG_INFO = MobileMsg::ERROR_CODE.merge(0 => "连接短信服务器失败",1 => "正常")

  scope :by_warning_code, lambda { |warning_code|
    if warning_code == 'error'
      where("message_warnings.warning_code <= 0")
    else
      where(["message_warnings.warning_code = ?", warning_code])
    end
  }
  scope :before_date, lambda {|date| where(["message_warnings.created_at < ?", 1.days.since(Time.zone.parse(date)).strftime("%Y-%m-%d")])}
  scope :after_date, lambda {|date| where(["message_warnings.created_at >= ?", date])}

  def display_name
    MSG_INFO[self.warning_code]
  end

end
