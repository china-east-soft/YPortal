class Agent::RegistrationsController < Devise::RegistrationsController
  layout 'devise'

  before_filter :update_sanitized_params, if: :devise_controller?
  after_filter :send_mail_to_customer_service, only: :create

  def new
    resource = build_resource
    resource.build_agent_info
  end

  def create
    @agent = Agent.new(agent_params.merge({not_required_password: true}))
    if @agent.save
      gflash success: "申请成功，请等等客服处理！"
      redirect_to new_agent_registration_url
    else
      gflash error: "请正确填写申请信息！"
      render :new
    end
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation)}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:name, :email, :password, :password_confirmation, :current_password)}
  end

  private
  def send_mail_to_customer_service
    if resource.persisted?
      AgentWorker.perform_async(resource.id)
    end
  end

  def agent_params
    params.require(:agent).permit(:email, {
      agent_info_attributes: [:category, :name, :industry, :province, :city, :contact, :telephone, :known_from, :remark, :status ]
    })
  end

end
