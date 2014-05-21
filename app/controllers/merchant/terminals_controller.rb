class Merchant::TerminalsController < MerchantController

  def index
    @terminals = current_merchant.terminals
  end

end