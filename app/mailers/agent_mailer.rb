class AgentMailer < ActionMailer::Base
  default from: "from@example.com"

  def active_after_registration(agent_id, password)
    @agent = Agent.find agent_id
    @password = password
    @signin_url = new_agent_session_url

    mail to: @agent.email, subject: "欢迎使用云链服务！"
  end

end
