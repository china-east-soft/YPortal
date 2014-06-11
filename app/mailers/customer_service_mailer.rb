class CustomerServiceMailer < ActionMailer::Base
  default from: "from@example.com"

  def notificate_merchant_registration(agent_id)
    @agent = Agent.find agent_id
    mail to: CONFIG['customer_service_email'], subject: "代理商注册通知"
  end

end
