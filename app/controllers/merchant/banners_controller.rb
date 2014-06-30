class Merchant::BannersController < MerchantController

  set_tab :banners

  before_action :set_banner, only: [:show, :edit, :update, :destroy]

  # GET /banners
  # GET /banners.json
  def index
    @banners = Banner.where(merchant_id: current_merchant.id)
  end

  # GET /banners/1
  # GET /banners/1.json
  def show
  end

  # GET /banners/new
  def new
    @banner = Banner.new
  end

  # GET /banners/1/edit
  def edit
  end

  # POST /banners
  # POST /banners.json
  def create
    @banner = Banner.new(banner_params)

    respond_to do |format|
      if @banner.save
        
        if params[:banner][:cover].present?
          format.html {
            render :action => "crop"
          }  
        else
          format.html { redirect_to [:merchant, @banner], notice: 'Banner was successfully created.' }
          format.json { render action: 'show', status: :created, location: @banner }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /banners/1
  # PATCH/PUT /banners/1.json
  def update
    respond_to do |format|
      if @banner.update(banner_params)

        if @banner.cropping?
          @banner.cover.reprocess!
        end

        if params[:banner][:cover].present?
          format.html {
            render :action => "crop"
          }  
        else
          format.html { redirect_to [:merchant, @banner], notice: 'Banner was successfully updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /banners/1
  # DELETE /banners/1.json
  def destroy
    @banner.destroy
    respond_to do |format|
      format.html { redirect_to merchant_banners_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_banner
      @banner = Banner.find(params[:id])
      @portal_style = @banner.portal_style
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def banner_params
      params.require(:banner).permit(:cover, :description, :url, :crop_x, :crop_y, :crop_w, :crop_h).merge!(merchant_id: current_merchant.id)
    end
end
