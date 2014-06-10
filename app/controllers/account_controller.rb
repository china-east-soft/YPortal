class AccountController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_account!
  layout 'account'

  def require_account
    unless current_account
      redirect_to new_account_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    return account_root_path
  end

end
