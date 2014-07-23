class Agent::MerchantsController < AgentController
  set_tab :merchant

  def index
    @merchants = current_agent.merchants.includes(:merchant_info).page(params[:page])
  end

end
