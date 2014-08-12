class Agent::SessionsController < Devise::SessionsController

  def auth
  end

  def create
    agent = Agent.find_by(email: params[:agent][:email].downcase)
    if agent.agent_info && agent.agent_info.active?
      super
    else
      gflash :error => "帐号还未激活，请耐心等待！"
      redirect_to new_agent_session_url
    end
  end


  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
