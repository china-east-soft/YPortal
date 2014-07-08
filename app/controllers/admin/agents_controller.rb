class Admin::AgentsController < AdminController
  before_action :set_agent, only: [:show, :edit, :update, :destroy, :merchants, :terminals, :active]

  set_tab :agents

  # GET /agents
  # GET /agents.json
  def index
    @agents = Agent.all.page params[:page]
  end

  def active
    @agent.active
    redirect_to admin_agents_url
  end

  def group
    set_tab :group
    @agents = Agent.all.page params[:page]
    @agents = @agents.map do |agent|
      account = 0
      login = 0
      AuthToken.uniq(:client_identifier).all.each do |auth_token|
        account += 1 if auth_token.account && auth_token.terminal.agent == agent
      end
      AuthToken.all.each do |auth_token|
        login += 1 if auth_token.terminal.agent == agent
      end

      [agent, account, login]
    end
  end

  def merchants
    set_tab :group
    @merchants = @agent.merchants.page params[:page]
  end

  def terminals
    set_tab :group
    @terminals = @agent.terminals.order(merchant_id: :asc).page params[:page]
  end

  # GET /agents/1
  # GET /agents/1.json
  def show
  end

  # GET /agents/new
  def new
    @agent = Agent.new
    @agent.build_agent_info
  end

  # GET /agents/1/edit
  def edit
  end

  # POST /agents
  # POST /agents.json
  def create
    @agent = Agent.new(agent_params)

    respond_to do |format|
      if @agent.save
        format.html { redirect_to [:admin, @agent], notice: 'Agent was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agent }
      else
        format.html { render action: 'new' }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agents/1
  # PATCH/PUT /agents/1.json
  def update
    respond_to do |format|
      if @agent.update(agent_params.merge(not_required_password: true))
        format.html { redirect_to [:admin, @agent], notice: 'Agent was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agents/1
  # DELETE /agents/1.json
  def destroy
    @agent.destroy
    respond_to do |format|
      format.html { redirect_to admin_agents_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent
      @agent = Agent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agent_params
      params.require(:agent).permit(:email, :password, :password_confirmation, {
          agent_info_attributes: [:category, :name, :industry, :city, :contact, :telephone, :known_from, :remark, :status ]
        })
    end
end
