class Admin::BottomAdsController < AdminController
  before_action :set_bottom_ad, only: [:show, :edit, :update, :destroy]
  set_tab :ads
  set_tab :bottom_ads, :sub_nav

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

    if @bottom_ad.save
      if BottomAd.date_must_be_exclusive(@bottom_ad)
        message = 'bottom_ad was successfully created.'
        gflash :success => message
      else
        message = '广告的起至时间和其它广告有冲突， 请仔细检查！'
        gflash :error => message
        flash[:error] = message
      end
      redirect_to [:admin, @bottom_ad]
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /bottom_ads/1
  # PATCH/PUT /bottom_ads/1.json
  def update
    if @bottom_ad.update(bottom_ad_params)
      if BottomAd.date_must_be_exclusive(@bottom_ad)
        message = 'bottom_ad was successfully created.'
        gflash :success => message
      else
        message = '广告的起至时间和其它广告有冲突， 请仔细检查！'
        gflash :error => message
        flash[:error] = message
      end

      redirect_to [:admin, @bottom_ad]
    else
      render action: 'edit'
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
    def setup
      @left_panel = "admin/landings/left_panel"
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_bottom_ad
      @bottom_ad = BottomAd.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bottom_ad_params
      params.require(:bottom_ad).permit(:start_at, :end_at, :url, :cover)
    end
end
