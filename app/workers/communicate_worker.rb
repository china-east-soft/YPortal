class CommunicateWorker
  include Sidekiq::Worker
  include Communicate
  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(auth_token_id)
    auth_token = AuthToken.find(auth_token_id)
    address = NatAddress.address(auth_token.mac.downcase)
    remote_ip, port, time = address.split("#")
    recv_data = send_to_terminal remote_ip, port, auth_token, 7
  end
end