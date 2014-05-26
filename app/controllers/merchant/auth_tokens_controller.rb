class Merchant::AuthTokensController < MerchantController
  include Communicate

  set_tab :auth_token
  
  before_action :set_auth_token, only: [:disable]

  def disable
    @auth_token.update_column(:status, AuthToken.statuses[:expired])

    if address = NatAddress.address(@auth_token.mac.downcase)
      remote_ip, port, time = address.split("#")
      
      recv_data = send_to_terminal remote_ip, port, auth_token, 4
      
      if recv_data.present?
        gflash :success => "The product has been created successfully!"
        redirect_to merchant_auth_tokens_path
      else
        gflash :now, :error => "Something went wrong."
        redirect_to merchant_auth_tokens_path
      end
    end
  end

  def index
    @auth_tokens = AuthToken.actived(current_merchant.id).all
  end


  private

    def set_auth_token
      @auth_token = AuthToken.find(params[:id])
    end

end
