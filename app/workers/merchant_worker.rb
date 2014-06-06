class MerchantWorker
  include Sidekiq::Worker

  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform()
  end
end
