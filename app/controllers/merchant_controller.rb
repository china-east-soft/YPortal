class MerchantController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_merchant!, except: :link_from_terminal
  layout 'merchant'


  def link_from_terminal
    mid = params[:mid]
    if params[:mid].present?
      #已登录
      if current_merchant
        #mid被添加过
        if Terminal.find_by mid: mid
          redirect_to merchant_root_url

        #mid未被添加过
        else
          redirect_to new_merchant_terminal_url(mid: mid)
        end

      #未登录
      else
        #mid被添加过
        if Terminal.find_by mid: mid
          redirect_to new_merchant_session_path

        #mid未被添加过
        else
          redirect_to new_merchant_registration_path(mid: mid)
        end
      end
    else
      redirect_to merchant_root_url
    end
  end

  def require_merchant
    unless current_merchant
      redirect_to new_merchant_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    return merchant_root_path
  end

end
