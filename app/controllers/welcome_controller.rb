class WelcomeController < ActionController::Base

  layout 'application'

  def index
  end

  def generate_verify_code
    if params[:uid].present?
      case params[:controller_name]
      when /account/
        auth_message = AuthMessage.where(mobile: params[:account_mobile], category: 2).first_or_initialize
      else
        auth_message = AuthMessage.where(mobile: params[:uid], category: 1).first_or_initialize
      end
    elsif params[:account_mobile].present?
      case params[:controller_name]
      when /merchant/
        auth_message = AuthMessage.where(mobile: params[:account_mobile], category: 0).first_or_initialize
      end
    end
    if auth_message && auth_message.save! && auth_message.send_result > 0
      render action: :generate_verify_code
    end
  end
  
end