class MerchantController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_merchant!
  layout 'merchant'

  def require_merchant
    unless current_merchant
      redirect_to new_merchant_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    return merchant_root_path
  end

end
