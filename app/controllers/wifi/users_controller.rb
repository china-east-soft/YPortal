#coding:utf-8
require 'net/http'
require 'socket'

class Wifi::UsersController < WifiController

  include Communicate

  def login
    params[:account] ||= {}
  end

  def sign_in

    params[:vtoken] = params[:account][:vtoken]
    
    if params[:account][:mobile] && params[:account][:verify_code] && params[:account] && params[:account][:vtoken]
      auth_message = AuthMessage.where(mobile: params[:account][:mobile], verify_code: params[:account][:verify_code]).first
      if auth_message
        auth_token = AuthToken.where(auth_token: params[:account][:vtoken]).first
        if auth_token
          case auth_token.status
            
          when "init"

          when "active"

          when "expired"

          end
          account = Account.where(mobile: params[:account][:mobile]).first_or_create
          if auth_token.update(expired_timestamp: Time.now.to_i + 1800, duration: 1800, status: AuthToken.statuses[:active], account_id: account.id)
            logger.info(auth_token.mac)
            logger.info(auth_token.auth_token)
            logger.info(NatAddress.address(auth_token.mac.downcase))
            if address = NatAddress.address(auth_token.mac.downcase)
              remote_ip, port, time = address.split("#")
              
              recv_data = send_to_terminal remote_ip, port, auth_token, 1

              if recv_data.present?
                redirect_to wifi_welcome_url
              else
                flash[:notice] = 'no recv....'
                auth_token.update(status: 0)
                render action: :login
              end

            else
              logger.info("no nat address")
              render action: :login
              
            end

          else
            flash[:notice] = auth_token.errors
            render action: :login
          end
        else
          flash[:notice] = "token is valid"
          render action: :login
        end
      else
        flash[:notice] = "auth_message is missing"
        render action: :login
      end
    else
      flash[:notice] = "手机号或者验证码不正确"
      render action: :login
    end
  end


end