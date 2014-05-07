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
          render action: :login
        else
          render action: :login
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
              logger.info(auth_token.mac)
              logger.info(NatAddress.address(auth_token.mac.downcase))
              if address = NatAddress.address(auth_token.mac.downcase)
                logger.info "send uuuu"
                remote_ip, port, time = address.split("#")
                $udp_client.connect(remote_ip, port)
                $udp_client.send "uuuu", 0

                redirect_to wifi_welcome_url
              else
                render action: :login
                
              end

            else
              @message = auth_token.errors
              render action: :login
            end
          else
            @message = "token is valid"
            render action: :login
          end
        else
          @message = "auth_message is missing"
          render action: :login
        end
      else
        @message = "手机号或者验证码不正确"
        render action: :login
      end
    end

  end

end