class Admin::TerminalsController < AdminController
  before_action :set_terminal, only: [:show, :edit, :update, :destroy, :update_status]
  before_action :get_agent_array, only: [:index, :new, :edit, :show]

  set_tab :terminals

  # GET /terminals
  # GET /terminals.json
  def index
    if params[:show].present?
      case params[:show]
      when 'normal'
        @terminals = Terminal.includes({merchant: :merchant_info}).normal.page(params[:page])
      when 'cancelling', 'cancelled',  'repair',  'trash'
        @terminals = Terminal.includes({merchant: :merchant_info}).where(status: Terminal.statuses[params[:show]]).page(params[:page])
      else
        @terminals = Terminal.all.page(params[:page])
      end
    else
      @terminals = Terminal.includes({merchant: :merchant_info}).page(params[:page])
    end
  end


  # GET /terminals/1
  # GET /terminals/1.json
  def show
    @logs = @terminal.operate_log.split(";").reverse
  end

  # GET /terminals/new
  def new
    @terminal = Terminal.new
  end

  # GET /terminals/1/edit
  def edit
  end

  # POST /terminals
  # POST /terminals.json
  def create
    @terminal = Terminal.new(terminal_params)

    respond_to do |format|
      if @terminal.save
        format.html { redirect_to [:admin, @terminal], notice: 'Terminal was successfully created.' }
        format.json { render action: 'show', status: :created, location: @terminal }
      else
        format.html { render action: 'new' }
        format.json { render json: @terminal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /terminals/1
  # PATCH/PUT /terminals/1.json
  def update
    respond_to do |format|
      if @terminal.update(terminal_params)
        format.html { redirect_to [:admin, @terminal], notice: 'Terminal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @terminal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /terminals/1
  # DELETE /terminals/1.json
  def destroy
    @terminal.destroy
    respond_to do |format|
      format.html { redirect_to admin_terminals_url }
      format.json { head :no_content }
    end
  end

  def export
    respond_to do |format|
      format.csv {
        send_data Terminal.to_csv,:type => "text/csv;charset=utf-8; header=present",
          :filename => "模板_#{Time.now.strftime("%Y%m%d")}.csv"
      }
    end
  end

  def import
    agent_id = params[:agent] || 0

    begin
      Terminal.import(params[:file], agent_id)
      @success = "导入成功."
    rescue => e
      @error = e
    end
    redirect_to admin_terminals_url, :flash => { error: @error.to_s, success: @success }
  end

  def update_status
    if Terminal::statuses.keys.include? params[:status]
      if @terminal.public_send params[:status], current_admin.email
        gflash success: "状态更新成功！"
      else
        gflash error: "状态更新失败!"
      end
    else
      gflash error: "错误请求!"
    end

    redirect_to admin_terminal_url(@terminal)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_terminal
      @terminal = Terminal.find(params[:id])
    end

    def get_agent_array
      @agent_array = Agent.all.map {|agent| [agent.agent_info.try(:name), agent.id] }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def terminal_params
      params.require(:terminal).permit(:admin, :mac, :imei, :sim_iccid, :agent_id)
    end
end
