class AgentController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_agent!
  layout 'agent'

  def require_agent
    unless current_agent
      redirect_to new_agent_session_path
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    return agent_root_path
  end

end