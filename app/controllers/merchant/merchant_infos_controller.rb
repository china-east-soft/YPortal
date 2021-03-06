class Merchant::MerchantInfosController < MerchantController

  before_action :set_merchant, :set_locale

  def show
    set_tab :merchant_info
  end

  def change_info
    if @merchant_info.update(merchant_info_params.merge(validate_base_info: true))
      flash.now[:success] = I18n.t("merchant.merchant_infos.flashes.successfully_updated")
    else
      flash.now[:warning] = I18n.t("merchant.merchant_infos.flashes.fail_updated")
    end

    render :show
  end

  def update_password
    if @merchant.update_with_password  merchant_password_params
      flash.now[:success] = I18n.t("merchant.merchant_infos.flashes.passwd_success_updated")
    else
      flash.now[:warning] = I18n.t("merchant.merchant_infos.flashes.passwd_fail_updated")
    end
    render :show
  end

  def update_other_base_info
    if @merchant.update merchant_other_params
      flash.now[:success] = "修改成功！"
    else
      flash.now[:error] = "修改失败！"
    end

    render :show
  end

  def shop_info
    set_tab :shop_info
  end

  def update_shop_info
    if @merchant_info.update(shop_info_params.merge(validate_shop_info: true))
      if @merchant_info.cropping?
        @merchant_info.shop_photo.reprocess!
      end

      if params[:merchant_info][:shop_photo].present?
        render :crop
      else
        flash[:success] = "保存成功！"
        redirect_to  shop_info_merchant_merchant_infos_url
      end
    else
      flash.now[:warning] = "请正确填写信息"
      render :shop_info
    end

  end

  def crop
  end

  private
  def set_merchant
    @merchant = current_merchant
    @merchant_info = @merchant.merchant_info || @merchant.build_merchant_info
  end

  def merchant_password_params
    params.require(:merchant).permit :password, :password_confirmation, :current_password
  end

  def merchant_info_params
    params.require(:merchant_info).permit :name, :industry, :contact_person_name, :contact_way
  end

  def shop_info_params
    params.require(:merchant_info).
      permit(
            :shop_photo, :shop_description, :shop_phone_one, :shop_phone_two, :shop_longitude,
            :shop_latitude, :province, :city, :area, :address, :crop_x, :crop_y, :crop_w,
            :crop_h
           )
  end

  def set_locale
     I18n.locale = params[:locale] || I18n.default_locale
  end

  def merchant_other_params
    params.require(:merchant).permit(:agent_id, :email)
  end

end
