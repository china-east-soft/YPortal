class Merchant::PortalStylesController < MerchantController
  before_action :set_portal_style, only: [:show, :edit, :update, :destroy, :save_order, :save_name]

  set_tab :portal_style

  # GET /portal_styles
  # GET /portal_styles.json
  def index
    @portal_style = PortalStyle.where(merchant_id: current_merchant.id).first_or_create
    @banners = @portal_style.banners
    @mboxes = @portal_style.valid_mboxes
    @deleted_mboxes = @portal_style.deleted_mboxes
  end

  # GET /portal_styles/1
  # GET /portal_styles/1.json
  def show
  end

  # GET /portal_styles/new
  def new
    @portal_style = PortalStyle.new
  end

  # GET /portal_styles/1/edit
  def edit
  end

  # POST /portal_styles
  # POST /portal_styles.json
  def create
    @portal_style = PortalStyle.new(portal_style_params)

    respond_to do |format|
      if @portal_style.save
        format.html { redirect_to [:merchant, @portal_style], notice: 'Portal style was successfully created.' }
        format.json { render action: 'show', status: :created, location: @portal_style }
      else
        format.html { render action: 'new' }
        format.json { render json: @portal_style.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /portal_styles/1
  # PATCH/PUT /portal_styles/1.json
  def update
    respond_to do |format|
      if @portal_style.update(portal_style_params)
        format.html { redirect_to [:merchant, @portal_style], notice: 'Portal style was successfully updated.' }
        format.json { head :no_content }
        format.js {  }
      else
        format.html { render action: 'edit' }
        format.json { render json: @portal_style.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_styles/1
  # DELETE /portal_styles/1.json
  def destroy
    @portal_style.destroy
    respond_to do |format|
      format.html { redirect_to merchant_portal_styles_url }
      format.json { head :no_content }
    end
  end

  def save_order
    mboxes = @portal_style.mboxes
    pids = params[:pids]
    mboxes.map{|mbox| mbox.update_column(:appid, pids.index(mbox.id.to_s)) }
  end

  def save_name
    @portal_style.update_column(:name, params[:name])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_portal_style
      @portal_style = PortalStyle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def portal_style_params
      params.require(:portal_style).permit(:name, :btn_style)
    end
end
