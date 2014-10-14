class Admin::BottomAdsController < AdminController
  before_action :set_bottom_ad, only: [:show, :edit, :update, :destroy]

  # GET /bottom_ads
  # GET /bottom_ads.json
  def index
    @bottom_ads = BottomAd.all
  end

  # GET /bottom_ads/1
  # GET /bottom_ads/1.json
  def show
  end

  # GET /bottom_ads/new
  def new
    @bottom_ad = BottomAd.new
  end

  # GET /bottom_ads/1/edit
  def edit
  end

  # POST /bottom_ads
  # POST /bottom_ads.json
  def create
    @bottom_ad = BottomAd.new(bottom_ad_params)

    respond_to do |format|
      if @bottom_ad.save
        format.html { redirect_to [:admin, @bottom_ad], notice: 'bottom_ad was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bottom_ad }
      else
        format.html { render action: 'new' }
        format.json { render json: @bottom_ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bottom_ads/1
  # PATCH/PUT /bottom_ads/1.json
  def update
    respond_to do |format|
      if @bottom_ad.update(bottom_ad_params)
        format.html { redirect_to [:admin, @bottom_ad], notice: 'bottom_ad was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bottom_ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bottom_ads/1
  # DELETE /bottom_ads/1.json
  def destroy
    @bottom_ad.destroy
    respond_to do |format|
      format.html { redirect_to admin_bottom_ads_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bottom_ad
      @bottom_ad = BottomAd.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bottom_ad_params
      params.require(:bottom_ad).permit(:start_at, :end_at, :url, :cover)
    end
end
