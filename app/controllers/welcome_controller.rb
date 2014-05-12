class WelcomeController < ActionController::Base

  def index
  end

  def generate_verify_code
    auth_message = AuthMessage.where(mobile: params[:uid], category: 1).first_or_initialize
    if auth_message.save! && auth_message.send_result > 0
      render action: :generate_verify_code
    end
  end
  
end