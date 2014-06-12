#coding:utf-8
require 'net/http'
require 'socket'

class Wifi::UsersController < WifiController
  before_action :required_login, only: :login_success

  include Communicate

  def login
    params[:account] ||= {}
  end

  def sign_in

    params[:vtoken] = params[:account][:vtoken]

    if params[:account][:mobile] && params[:account][:verify_code] && params[:account] && params[:account][:vtoken]
      auth_message = AuthMessage.where(mobile: params[:account][:mobile], verify_code: params[:account][:verify_code], category: 1).first
      if auth_message
        auth_token = AuthToken.where(auth_token: params[:account][:vtoken]).first
        if auth_token
          terminal = auth_token.terminal
          duration = terminal.duration || 14400

          account = Account.where(mobile: params[:account][:mobile]).first_or_create

          case auth_token.status
          when "init"
            if auth_token.update_and_send_to_terminal(expired_timestamp: Time.now.to_i + duration, duration: duration, status: AuthToken.statuses[:active], account_id: account.id)
              gflash :success => "已经认证成功可以直接上网!"
              redirect_to login_success_wifi_users_url(vtoken: auth_token.auth_token)
            else
              message = "认证失败!"
              gflash :error => message
              render action: :login
            end
          when "active"
            gflash :success => "已经认证成功可以直接上网!"
            redirect_to login_success_wifi_users_url(vtoken: auth_token.auth_token)
          when "expired"
            gflash :error => "认证已经过期，请重新认证!"
            redirect_to wifi_merchant_url(client_identifier: auth_token.client_identifier, mac: auth_token.mac)
          end
        else
          gflash :notice => "请连接wifi!"
          render action: :login
        end
      else
        gflash :notice => "请获取验证码!"
        render action: :login
      end
    else
      gflash :notice => "手机号或者验证码不正确!"
      render action: :login
    end
  end

  def quick_login
    params[:account] ||= {}

    if params[:mid].present?
      process_preview
    elsif params[:vtoken].present?
      process_vtoken_present
    else
      redirect_to wifi_merchant_url
    end
  end

  def login_success
    @merchant = terminal_merchant
    @products = @merchant.products.hot.take 2
    @activities = terminal_merchant.activities.actived.where(hot: true).take 2
  end

  private

  def process_preview
    redirect_to login_success_wifi_users_url(mid: params[:mid])
  end

  def process_vtoken_present
    @auth_token = AuthToken.where(auth_token: params[:vtoken]).first
    if @auth_token.present?
      if @auth_token.init?
        process_init_update_token_and_communicate_with_terminal
      elsif @auth_token.active?
        gflash :success => "已经认证成功可以直接上网!"
        redirect_to login_success_wifi_users_url(vtoken: @auth_token.auth_token)
      elsif @auth_token.expired?
        gflash :error => "认证已经过期，请重新认证!"
        redirect_to wifi_merchant_url(client_identifier: @auth_token.client_identifier, mac: @auth_token.mac)
      end
    else
      gflash :error => "请连接wifi!"
      render :login
    end
  end

  def process_init_update_token_and_communicate_with_terminal
    terminal = @auth_token.terminal
    duration = @terminal.duration || 14400

    if @auth_token.update_and_send_to_terminal(expired_timestamp: Time.now.to_i + duration, duration: duration, status: AuthToken.statuses[:active])
      gflash :success => "已经认证成功可以直接上网!"
      redirect_to login_success_wifi_users_url(vtoken: @auth_token.auth_token)
    else
      message = "认证失败!"
      gflash :error => message
      render action: :login
    end
  end

  def required_login
    if params[:mid].present?
      @terminal = Terminal.where(status: Terminal.statuses[:active], mid: params[:mid]).first
    elsif params[:vtoken].present?
      @auth_token = AuthToken.where(auth_token: params[:vtoken]).first
      unless @auth_token.present? && @auth_token.active?
        redirect_to wifi_merchant_url(client_identifier: @auth_token.client_identifier, mac: @auth_token.mac)
      end
    else
      redirect_to wifi_merchant_url(client_identifier: @auth_token.client_identifier, mac: @auth_token.mac)
    end
  end

end
