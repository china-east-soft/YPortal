class Admin::MerchantsController < AdminController
  before_action :set_merchant, only: [:show, :edit, :update, :destroy]

  set_tab :merchants

  # GET /merchants
  # GET /merchants.json
  def index
    @merchants = Merchant.all.page(params[:page])
  end

  # GET /merchants/1
  # GET /merchants/1.json
  def show
  end

  # GET /merchants/new
  def new
    @merchant = Merchant.new
    @merchant.build_merchant_info
  end

  # GET /merchants/1/edit
  def edit
  end

  # POST /merchants
  # POST /merchants.json
  def create
    @merchant = Merchant.new(merchant_params.merge({add_by_admin: true}))

    respond_to do |format|
      if @merchant.save
        format.html {
          gflash successs: "成功创建商户!"
          redirect_to [:admin, @merchant]
        }

        format.json { render action: 'show', status: :created, location: @merchant }
      else
        format.html {
          gflash error: "创建商户错误!"
          render action: 'new'
        }

        format.json { render json: @merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /merchants/1
  # PATCH/PUT /merchants/1.json
  def update
    respond_to do |format|
      if @merchant.update(merchant_params)
        format.html { redirect_to [:admin, @merchant], notice: 'Merchant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /merchants/1
  # DELETE /merchants/1.json
  def destroy
    @merchant.destroy
    respond_to do |format|
      format.html { redirect_to admin_merchants_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merchant
      @merchant = Merchant.find(params[:id])
      @merchant_info = @merchant.merchant_info
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def merchant_params
      params.require(:merchant).permit(:mobile, :mid, :email, :password, :password_confirmation, {
          merchant_info_attributes: [:name, :industry, :province, :city, :area, :circle, :address, :contact_person_name, :mobile, :secondary]
        })
    end
end
