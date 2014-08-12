class AdminController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_admin!
  helper_method :date_parts, :app_names, :app_display_name, :terminal_collections, :personal?, :public?

  layout 'admin'

  def require_admin
    unless current_admin
      redirect_to new_admin_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    return admin_root_path
  end


  private
    def date_parts
      {"day" => '天',"week" => '周',"month" => '月',"year" => '年'}
    end

    def app_names
      AppVersion::VERSION_DISPLAY_NAMES.merge({'all' => '全部'})
    end

    def app_display_name(name)
      if AppVersion::VERSION_DISPLAY_NAMES[name]
        AppVersion::VERSION_DISPLAY_NAMES[name]
      else
        '未知'
      end
    end

    def terminal_collections(terminal_id)
      if terminal_id =~ /^\d+$/
        terminal = Terminal.find terminal_id
        [['全部', 'all'], [terminal.mac.to_s, terminal_id.to_s], ['', '']]
      else
        [['全部', 'all'], ['', '']]
      end
    end

    def personal?
      params[:branch].present? && params[:branch] == 'personal'
    end

    def public?
      !personal?
    end

end
