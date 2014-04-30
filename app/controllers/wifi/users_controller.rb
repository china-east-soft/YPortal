#coding:utf-8
require 'net/http'
require 'socket'

class Wifi::UsersController < WifiController

  def login

  end

  def sign_in
    if params[:verify].present?
      if params[:mobile]
        auth_message = AuthMessage.where(mobile: params[:mobile]).first_or_initialize
        if auth_message.save && auth_message.send_result > 0
          redirect_to wifi_login_url(vtoken: params[:account][:vtoken]), flash: auth_message.send_result
        else
          redirect_to wifi_login_url(vtoken: params[:account][:vtoken]), flash: auth_message.send_result
        end
      end
    end

    if params[:sign_in].present?
      if params[:mobile] && params[:verify_code] && params[:account] && params[:account][:vtoken]
        auth_message = AuthMessage.where(mobile: params[:mobile], verify_code: params[:verify_code]).first
        if auth_message
          auth_token = AuthToken.where(auth_token: params[:account][:vtoken]).first
          if auth_token
            account = Account.where(mobile: params[:mobile]).first_or_create
            if auth_token.update(expired_timestamp: 4*3600, status: 1, account_id: account.id)
              logger.info API::V1::MACS.inspect
              logger.info auth_token.mac
              if API::V1::MACS[auth_token.mac.to_sym]
                # uri = URI.parse("http://10.10.10.254:2060/wifidog/auth?token=#{auth_token.auth_token}&mac=#{auth_token.mac}&client_identifier=#{auth_token.client_identifier}")

                # Net::HTTP.start(API::V1::MACS[auth_token.mac.to_sym][:ip], API::V1::MACS[auth_token.mac.to_sym][:port]) do |http|
                #   request = Net::HTTP::Post.new uri.request_uri

                #   response = http.request request # Net::HTTPResponse object
                # end


                # hostname = API::V1::MACS[auth_token.mac.to_sym][:ip]
                # port = API::V1::MACS[auth_token.mac.to_sym][:port]

                # client = TCPSocket.open(hostname, port) 
                # client.send(" testtxxxxxxxx xxxx oooooooo 9999999999\n", 0) # 0 means standard packet 
                # client.close

                redirect_to wifi_welcome_url
              else
                redirect_to wifi_login_url(vtoken: params[:account][:vtoken])
                
              end

            else
              @message = auth_token.errors
              redirect_to wifi_login_url(vtoken: params[:account][:vtoken])
            end
          else
            @message = "token is valid"
            redirect_to wifi_login_url(vtoken: params[:account][:vtoken])
          end
        else
          @message = "auth_message is missing"
          redirect_to wifi_login_url(vtoken: params[:account][:vtoken])
        end
      else
        @message = "手机号或者验证码不正确"
        redirect_to wifi_login_url(vtoken: params[:account][:vtoken])
      end
    end

  end

end