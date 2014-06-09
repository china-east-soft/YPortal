class Merchant::RegistrationsController < Devise::RegistrationsController

  layout 'devise'

  before_filter :update_sanitized_params, if: :devise_controller?
  after_filter :send_meail_to_customer_service

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:mobile, :verify_code, :password, :password_confirmation, :mid)}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:name, :email, :password, :password_confirmation, :current_password)}
  end

  def send_meail_to_customer_service
    if resource.persisted?
      MerchantWorker.perform_async(resource.id)
    end
  end

end
