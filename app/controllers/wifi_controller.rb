class WifiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'wifi'

  def current_terminal
    if params[:mid]
      Terminal.where(mid: params[:mid]).first
    elsif params[:vtoken]
      auth_token = AuthToken.where(auth_token: params[:vtoken]).first
      auth_token.terminal
    end
  end

end