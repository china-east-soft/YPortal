class Merchant::MerchantInfosController < ApplicationController
  layout 'merchant'

  before_action :set_merchant, except: [:map]

  def show
  end

  def change_info
    if @merchant_info.update  merchant_info_params
      flash.now[:success] = "修改成功"
    else
      flash.now[:warning] = "请正确填写基本信息"
    end
    render :show
  end

  def update_password
    if @merchant.update_with_password  merchant_params
      flash.now[:success] = "密码修改成功"
    else
      flash.now[:warning] = "请正确填写密码"
    end
    render :show
  end

  def map
  end

  private
  def set_merchant
    @merchant = current_merchant
    @merchant_info = @merchant.merchant_info
  end

  def merchant_params
    params.require(:merchant).permit(:password, :password_confirmation, :current_password)
  end
  def merchant_info_params
    params.require(:merchant_info).permit(:name, :industry, :address, :contact_person_name, :contact_way)
  end

end
