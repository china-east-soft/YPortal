class Merchant::TerminalsController < MerchantController

  before_action :set_terminal, only: [:edit, :update, :cancelling]
  set_tab :terminal

  def index
    @terminals = current_merchant.terminals
  end

  def new
    @terminal = Terminal.new
  end

  def edit
  end

  def create
    @terminal = Terminal.where(mid: terminal_params[:mid], status: AuthToken.statuses[:init]).first

    if @terminal && @terminal.active(current_merchant.id)
      gflash :success => "The product has been created successfully!"
      redirect_to merchant_terminals_path
    else
      @terminal = Terminal.new
      gflash error: "fail to add terminal, please ensure mid is right or contace custom service."
      # render :new
      redirect_to new_merchant_terminal_path
    end
  end

  # PATCH/PUT /terminals/1
  # PATCH/PUT /terminals/1.json
  def update
    respond_to do |format|
      if @terminal.update(terminal_params)
        format.html { redirect_to merchant_terminals_path, notice: 'Terminal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @terminal.errors, status: :unprocessable_entity }
      end
    end
  end

  #退货
  def cancelling
    @terminal.cancelling
    gflash success: "申请退货成功，请等待处理"
    redirect_to merchant_terminals_url
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_terminal
      @terminal = current_merchant.terminals.find params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def terminal_params
      params.require(:terminal).permit(:mid, :duration, :beaut_duration)
    end

end
