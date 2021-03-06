class AccountController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_account!, except: [:signing]
  before_filter :required_terminal, :required_client_identifier
  layout 'account'

  helper_method :current_terminal, :terminal_merchant, :current_portal_style

  def require_account
    unless current_account
      redirect_to new_account_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    account_signing_path(mac: params[:mac], client_identifier: params[:client_identifier])
  end


  def required_terminal
    terminal = Terminal.where(status: Terminal.statuses[:active], mac: params[:mac]).first
    unless terminal
      gflash :error => "请连接wifi!"
      redirect_to error_wifi_merchants_url
    end
  end

  def required_client_identifier
    unless params[:client_identifier].present?
      gflash :error => "请连接wifi!"
      redirect_to error_wifi_merchants_url
    end
  end

  def current_terminal
    Terminal.where(mac: params[:mac]).first
  end

  def terminal_merchant
    current_terminal.merchant
  end

  def current_portal_style
    terminal_merchant.current_portal_style
  end

end
