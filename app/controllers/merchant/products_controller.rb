class Merchant::ProductsController < MerchantController
  skip_before_filter :verify_authenticity_token

  before_action :require_merchant
  before_action :find_product, only: [:show, :edit, :update, :destroy]

  layout 'wifi'

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
    @hot_products = current_merchant.products.hot
    @products = current_merchant.products.all - @hot_products
  end

  def edit
  end

  def update
    if @product.update product_params
    else
    end
  end

  def destroy
    @product.destroy
  end

  private
  def product_params
    params.require(:product).permit(:name, :product_photo, :price, :description)
  end

  def find_product
    @product = current_merchant.products.find params[:id]
  end
end
