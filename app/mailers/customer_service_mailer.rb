class CustomerServiceMailer < ActionMailer::Base
  default from: "from@example.com"

  def notificate_merchant_registration(merchant_id)
    @merchant = Merchant.find merchant_id
    mail to: CONFIG['customer_service_email'], subject: "商户注册通知"
  end

end
