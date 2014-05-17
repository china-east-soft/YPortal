class WelcomeController < ActionController::Base

  layout "wifi"

  def index
  end

  def generate_verify_code
    if params[:uid].present?
      auth_message = AuthMessage.where(mobile: params[:uid], category: 1).first_or_initialize
    elsif params[:account_mobile].present?
      auth_message = AuthMessage.where(mobile: params[:account_mobile], category: 0).first_or_initialize
    end
    if auth_message.save! && auth_message.send_result > 0
      render action: :generate_verify_code
    end
  end
  
end