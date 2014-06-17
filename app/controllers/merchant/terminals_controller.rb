class Merchant::TerminalsController < MerchantController

  before_action :set_terminal, only: [:edit, :update]
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
    if @terminal && @terminal.update(merchant_id: current_merchant.id, status: AuthToken.statuses[:active], added_by_merchant_at: Time.now)
      gflash :success => "The product has been created successfully!"
      redirect_to merchant_terminals_path
    else
      @terminal = Terminal.new
      gflash :now, :error => "Something went wrong."
      render("new")
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

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_terminal
      @terminal = Terminal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def terminal_params
      params.require(:terminal).permit(:mid, :duration, :beaut_duration)
    end

end
