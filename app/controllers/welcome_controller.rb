class WelcomeController < ActionController::Base

  layout "wifi"

  def index
  end

  def generate_verify_code
    if params[:uid].present?
      auth_message = AuthMessage.where(mobile: params[:uid], category: 1).first_or_initialize
    elsif params[:account_mobile].present?
      case params[:controller_name]
      when /app_account/
        auth_message = AuthMessage.where(mobile: params[:account_mobile], category: 2).first_or_initialize
      when /merchant/
        auth_message = AuthMessage.where(mobile: params[:account_mobile], category: 0).first_or_initialize
      end
    end
    if auth_message.save! && auth_message.send_result > 0
      render action: :generate_verify_code
    end
  end
  
end