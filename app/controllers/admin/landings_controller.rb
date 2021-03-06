class Admin::LandingsController < AdminController
  before_action :set_landing, only: [:show, :edit, :update, :destroy]

  set_tab :ads
  set_tab :landings, :sub_nav

  # GET /landings
  # GET /landings.json
  def index
    @landings = Landing.all
  end

  # GET /landings/1
  # GET /landings/1.json
  def show
  end

  # GET /landings/new
  def new
    @landing = Landing.new
  end

  # GET /landings/1/edit
  def edit
  end

  # POST /landings
  # POST /landings.json
  def create
    @landing = Landing.new(landing_params)

    if @landing.save
      if Landing.date_must_be_exclusive(@landing)
        message = 'landing was successfully created.'
        gflash :success => message
      else
        message = '广告的起至时间和其它广告有冲突， 请仔细检查！'
        gflash :error => message
        flash[:error] = message
      end

      redirect_to [:admin, @landing]
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /landings/1
  # PATCH/PUT /landings/1.json
  def update
    if @landing.update(landing_params)
      if Landing.date_must_be_exclusive(@landing)
        message = 'landing was successfully created.'
        gflash :success => message
      else
        message = '广告的起至时间和其它广告有冲突， 请仔细检查！'
        gflash :error => message
        flash[:error] = message
      end

      redirect_to [:admin, @landing]
    else
      render action: 'edit'
    end
  end

  # DELETE /landings/1
  # DELETE /landings/1.json
  def destroy
    @landing.destroy
    respond_to do |format|
      format.html { redirect_to admin_landings_url }
      format.json { head :no_content }
    end
  end

  private
    def setup
      @left_panel = "admin/landings/left_panel"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_landing
      @landing = Landing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def landing_params
      params.require(:landing).permit(:start_at, :end_at, :url, :cover_iphone, :cover_iphone2x, :cover_iphone586, :cover_andriod, :cover_ipad, :cover_ipad_retina)
    end
end
