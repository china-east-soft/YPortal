class HuanxinWorker
  include Sidekiq::Worker
  include Huanxin

  sidekiq_options queue: "high"
  sidekiq_options retry: false

  def perform(user_id, operate_method)
    unless RESTFUL_API.include?(operate_method)
      logger.error "#{operate_method} is not in operation list."
      return
    end
    user = User.find user_id
    public_send(operate_method, user)
  end

end
