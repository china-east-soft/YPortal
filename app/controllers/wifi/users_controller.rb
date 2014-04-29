class Wifi::UsersController < WifiController

  def login

  end

  def sign_in
    if params[:verify].present?
      if params[:mobile]
        auth_message = AuthMessage.where(mobile: params[:mobile]).first_or_initialize
        if auth_message.save && auth_message.send_result > 0
          render :login, flash: auth_message.send_result
        else
          render :login, flash: auth_message.send_result
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
              redirect_to wifi_welcome_url
            else
              @message = auth_token.errors
              render :login
            end
          else
            @message = "token is valid"
            render :login
          end
        else
          @message = "auth_message is missing"
          render :login
        end
      else
        @message = "手机号或者验证码不正确"
        render :login
      end
    end

  end

end