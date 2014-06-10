class AgentWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(merchant_id)
    CustomerServiceMailer.notificate_merchant_registration(merchant_id).deliver
  end
end

