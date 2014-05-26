class Merchant::AuthTokensController < MerchantController

  set_tab :auth_token
  
  before_action :set_auth_token, only: [:disable]

  def disable
  end

  def index
    @auth_tokens = AuthToken.actived(current_merchant.id)
  end


  private

    def set_auth_token
      @banner = Banner.find(params[:id])
    end

end
