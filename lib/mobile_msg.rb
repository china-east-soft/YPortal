#coding:utf-8
require 'net/http'
require 'cgi'

module MobileMsg
  DOMAIN = 'utf8.sms.webchinese.cn'
  UID = 'yunlian'
  KEY = '40943de2d4f73644b2d7'

  ERROR_CODE = {
     -1 => '没有该用户账户',
     -2 => '密钥不正确',
     -3 => '短信数量不足',
     -4 => '手机号格式不正确',
    -11 => '该用户被禁用',
    -14 => '短信内容出现非法字符',
    -41 => '手机号码为空',
    -42 => '短信内容为空',
    -51 => '短信签名格式不正确'
  }


  def send_out sms_mob, sms_text
    params = { Uid: UID, Key: KEY, smsMob: sms_mob, smsText: sms_text }
    begin
      result = http_get(DOMAIN, "/", params).to_i
    rescue
      result = 0
    end
    #log sms_mob, sms_text, result
    result
  end

  private
    def http_get(domain, path, params)
      return Net::HTTP.get(domain, "#{path}?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&'))) if not params.nil?
      return Net::HTTP.get(domain, path)
    end

    def log sms_mob, sms_text, result
      if result <=0 && result != -4
        title = "短信发送失败"
        body  = "警告信息： #{MessageWarnning::MSG_INFO[result]}." if MessageWarnning::MSG_INFO.keys.include?(result)
        AdminMailer.warnning_notify(title, body, "").deliver
      end

      warnning_code = [result, 1].min
      MessageWarnning.create(mobile_number: sms_mob, warnning_code: warnning_code, message: sms_text)
    end

end