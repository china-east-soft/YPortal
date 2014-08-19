class WifiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'wifi'

  helper_method :current_terminal, :terminal_merchant, :current_portal_style

  def current_terminal
    if params[:mid].present?
      Terminal.where(mid: params[:mid]).first
    elsif params[:vtoken].present?
      auth_token = AuthToken.where(auth_token: params[:vtoken]).first
      auth_token.terminal
    elsif params[:mac].present?
      Terminal.where(mac: params[:mac].downcase).first
    end
  end

  def terminal_merchant
    current_merchant || current_terminal.merchant
  end

  def current_portal_style
    terminal_merchant.current_portal_style
  end

end
