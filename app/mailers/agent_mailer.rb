class AgentMailer < ActionMailer::Base
  default from: "from@example.com"

  def active_after_reg(agent_id)
    @agent = Agent.find agent_id
  end

end
