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
        if current_merchant.terminals.find_by mid: mid
          gflash notice: "此终端已经添加过了， 请前往终端管理页面查看"
          redirect_to merchant_root_url

        #mid未被添加过
        else
          @terminal = Terminal.where(mid: mid, status: AuthToken.statuses[:init]).first
          if @terminal && @terminal.update(merchant_id: current_merchant.id, status: AuthToken.statuses[:active], added_by_merchant_at: Time.now)

            gflash success: "终端添加成功，请前往终端管理页面查看"
          else
            gflash notice: "终端添加失败，终端不存在或已经被添加过了，请前往终端管理界面添加"
          end

          redirect_to merchant_root_path
        end

      #未登录
      else
        terminal = Terminal.find_by mid: mid
        if terminal
          #mid未被添加过
          if terminal.init?
            redirect_to new_merchant_registration_path(mid: mid)

          #mid被添加过
          else
            gflash notice: "mid已经添加过了, 请登录！"
            redirect_to new_merchant_session_path
          end
        else
          gflash notice: "mid不存在，请登录后前往终端管理界面添加！"
          redirect_to merchant_root_url
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
