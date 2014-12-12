class HuanxinFriendWorker
  include Sidekiq::Worker
  include Huanxin

  sidekiq_options queue: "high"
  sidekiq_options retry: false

  def perform(user_id, operate_method, other_user_id)
    unless FRIEND_RESTFUL_API.include?(operate_method)
      logger.error "#{operate_method} is not in operation list."
      return
    end
    user = User.find user_id
    other_user = User.find other_user_id
    public_send(operate_method, user, other_user)
  end
end
