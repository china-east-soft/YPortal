class Account::AccountsController < AccountController

  include Communicate
  include PrivateKey
  include Vtoken
  layout 'wifi'

  def signing
    @auth_token = AuthToken.where(mac: params[:mac], 
      client_identifier: params[:client_identifier], 
      status: [AuthToken.statuses[:init],AuthToken.statuses[:active]]).first
    
    if @auth_token
      case @auth_token.status
      when 'init'
        render :signing
      when 'active'
        redirect_to login_success_wifi_users_url(vtoken: @auth_token.auth_token)
      end
    else
      vtoken = generate_vtoken params[:mac], params[:client_identifier], Time.now.to_i
      @auth_token = AuthToken.create(auth_token: vtoken,
                  mac: params[:mac], 
                  client_identifier: params[:client_identifier], 
                  status: AuthToken.statuses[:init],
                  terminal_id: current_terminal.id,
                  account_id: current_account.id ,
                  merchant_id: current_terminal.merchant_id)
      render :signing
    end
  end

  def sign_on
    @auth_token = AuthToken.where(mac: params[:mac], 
      client_identifier: params[:client_identifier], 
      auth_token: params[:vtoken]).first
    case @auth_token.status
    when "init"
      account = @auth_token.account
      duration = current_terminal.duration || 14400
      
      if @auth_token.update_and_send_to_terminal(expired_timestamp: Time.now.to_i + duration, duration: duration, status: AuthToken.statuses[:active])
        gflash :success => "已经签到成功可以直接上网!"
        redirect_to login_success_wifi_users_url(vtoken: @auth_token.auth_token)
      else
        message = "签到失败!"
        gflash :error => message
        render action: :signing
      end

    when "active"
      gflash :success => "已经签到成功可以直接上网!"
      redirect_to login_success_wifi_users_url(vtoken: @auth_token.auth_token)
    end
  end



end