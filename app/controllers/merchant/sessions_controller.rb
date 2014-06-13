class Merchant::SessionsController < Devise::SessionsController

  layout 'devise'

  def auth
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)

    add_terminal_to_merchant

    if !session[:return_to].blank?
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      respond_with resource, :location => after_sign_in_path_for(resource)
    end

  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def add_terminal_to_merchant
    #添加终端到代码，处理从终端过的到登录消息
    if params[:mid].present?
      @terminal = Terminal.where(mid: params[:mid], status: AuthToken.statuses[:init]).first
      if @terminal && @terminal.update(merchant_id: current_merchant.id, status: AuthToken.statuses[:active])
        gflash :success => "添加终端成功，请前往终端管理页面查看。"
      else
        gflash :error => "添加终端失败！ 请前往终端管理页面手动添加."
      end
    end
  end
end
