class DeveloperMailer < ActionMailer::Base
  default from: "from@example.com"

  def system_error_email(info, log)
    @info = info
    @log = log
    mail to: CONFIG['developer_email'], subject: "Portal 系统性错误，请尽快处理！"
  end

end
