class WifiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'wifi'

  helper_method :current_terminal, :terminal_merchant

  def current_terminal
    if params[:mid]
      Terminal.where(mid: params[:mid]).first
    elsif params[:vtoken]
      auth_token = AuthToken.where(auth_token: params[:vtoken]).first
      auth_token.terminal
    elsif params[:mac]
      Terminal.where(mac: params[:mac].downcase).first
    end
  end

  def terminal_merchant
    current_merchant || current_terminal.merchant
  end

end