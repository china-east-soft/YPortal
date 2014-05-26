class Merchant::TerminalsController < MerchantController

  def index
    @terminals = current_merchant.terminals
  end

  def new
    @terminal = Terminal.new
  end

  def create
    @terminal = Terminal.where(mid: terminal_params[:mid], status: AuthToken.statuses[:init]).first
    if @terminal && @terminal.update(merchant_id: current_merchant.id, status: AuthToken.statuses[:active])
      gflash :success => "The product has been created successfully!"
      redirect_to merchant_terminals_path
    else
      @terminal = Terminal.new
      gflash :now, :error => "Something went wrong."
      render("new")
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def terminal_params
      params.require(:terminal).permit(:mid)
    end

end