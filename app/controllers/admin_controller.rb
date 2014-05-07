class AdminController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_admin!
  layout 'admin'

  def require_admin
    unless current_admin
      redirect_to new_admin_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    return admin_root_path
  end

end
