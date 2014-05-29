class Merchant::ProductsController < MerchantController
  skip_before_filter :verify_authenticity_token

  before_action :require_merchant

  def create
     @product = current_merchant.products.create product_params
     if @product.errors.empty?
       gflash success: t(".success_add_product")
     else
       gflash error: t(".failed_to_add_product")
     end

     redirect_to edit_merchant_mbox_url(params[:mbox_id])
  end

  private
  def product_params
    params.require(:product).permit(:name, :product_photo, :price, :description)
  end
end
