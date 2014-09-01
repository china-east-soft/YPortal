class Merchant::ProductsController < MerchantController
  skip_before_filter :verify_authenticity_token

  before_action :require_merchant
  before_action :find_product, only: [:show, :edit, :update, :destroy, :set_hot, :unset_hot]

  set_tab :products


  def create
     @product = current_merchant.products.create product_params
     if @product.errors.empty?
       gflash success: "成功添加商品！"
     else
       gflash error: "添加商品失败，请正确填写所需信息！"
     end

     redirect_to edit_merchant_mbox_url(params[:mbox_id])

  end

  def show
  end

  def index
    @products = current_merchant.products.all
  end

  def edit
  end

  def update
    if @product.update product_params
      gflash :success => "修改产品成功!"
      redirect_to merchant_product_url(@product)
    else
      gflash :error => "修改产品失败, 请填写正确信息"
      render :edit
    end
  end

  def destroy
    @product.destroy
    gflash :success => "删除产品成功！"
    redirect_to merchant_products_url
  end


  def set_hot
    @product.update_attributes(hot: 1)
    gflash :success => "设置热销产品成功!"
    redirect_to merchant_product_url(@product)
  end

  def unset_hot
    @product.update_attributes(hot: 0)
    gflash :success => "取消设置热销产品成功!"
    redirect_to merchant_product_url(@product)
  end

  private
  def product_params
    params.require(:product).permit(:name, :product_photo, :price, :description, :hot)
  end

  def find_product
    @product = current_merchant.products.find params[:id]
  end
end
