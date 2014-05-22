class Merchant::MerchantInfosController < ApplicationController
  layout 'merchant'

  before_action :set_merchant
  before_action :current_password_required, only: [:change_password]

  def show
  end

  def change_contact_info
    if @merchant_info.update_attributes params.require(:merchant_info).permit(:contact)
      flash.now[:success] = "修改成功"
    else
      flash.now[:error] = "请正确填写姓名和联系方式"
    end
    render :show
  end
  def change_password
    if @merchant.update_attributes params.require(:merchant).permit(:password, :password_confirmation)
      flash.now[:success] = "修改成功"
    else
      flash.now[:error] = "请正确填写姓名和联系方式"
    end
    render :show
  end

  private
  def set_merchant
    @merchant = current_merchant
    @merchant_info = @merchant.merchant_info
  end
  def current_password_required
    unless params[:current_password] && @merchant.authenticate(params[:current_password])
    end
  end
end
