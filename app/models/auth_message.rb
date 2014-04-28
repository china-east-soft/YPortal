# coding:utf-8
require 'securerandom'
require 'pp'

class AuthMessage < ActiveRecord::Base
  include MobileMsg
  attr_accessor :send_result

  validates :mobile, presence: true
  validates :mobile, format: /\A\d{11}\z/
  validates :mobile, uniqueness: true

  before_save do
    self.verify_code = generate_verify_code
    self.activated_at = Time.now + (10 * 60)
  end

  after_save do
    message = "注册验证码：#{verify_code}，欢迎使用WiFi上网帐号"
    self.send_result = send_out(mobile, message)
  end

  private

    # repeat verify_code if the user did not use the last verify_code
    def generate_verify_code
      repeat_verify_code = false
      account = Account.where(mobile: self.mobile).first
      if account && last_signin = account.account_signins.last
        if last_signin.created_at < last_auth_message.updated_at
          repeat_verify_code = last_auth_message.verify_code
        end
      else
        if last_auth_message
          repeat_verify_code = last_auth_message.verify_code
        end
      end

      if repeat_verify_code
        return repeat_verify_code
      else
        return SecureRandom.random_number(10000).to_s.rjust(4, '0')
      end      
    end

    def last_auth_message
      AuthMessage.where(mobile: self.mobile).order("id desc").last
    end

end