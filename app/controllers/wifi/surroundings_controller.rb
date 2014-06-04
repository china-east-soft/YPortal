class Wifi::SurroundingsController < WifiController

  before_action :set_merchant_info

  def index
    
    @merchant_infos = MerchantInfo.where.not(merchant_id: terminal_merchant.id)
    @merchant_infos = @merchant_infos.all.page(1).per(5)

    @distances = ["全部距离","100 m","500 m","1 km","5 km"]
    @industries = ["全部分类"] + MerchantInfo.uniq.pluck('industry').compact
    @order_bys = %w{ 默认排序 距离最近 }

  end

  def load
    @merchant_infos = MerchantInfo.where.not(merchant_id: terminal_merchant.id)
    if params[:distance] != '全部距离' || params[:order_by] == "距离最近"
      if params[:distance] != '全部距离'
        distance, units = params[:distance].split(' ')
        sym_unit = case units
        when "km" then :km
        when "m" then :mi
        end
        @merchant_infos = @merchant_infos.near([@merchant_info.shop_latitude, @merchant_info.shop_longitude], distance.to_i, units: sym_unit)
      else
        @merchant_infos = @merchant_infos.near([@merchant_info.shop_latitude, @merchant_info.shop_longitude])
      end
      if params[:order_by] == "距离最近"
        @merchant_infos.reorder('distance')
      end
    end
    @merchant_infos = @merchant_infos.where(industry: params[:industry]) if params[:industry] != '全部分类'
    @merchant_infos = @merchant_infos.page(params[:page]).per(5)
  end

  private

    def set_merchant_info
      @merchant_info = terminal_merchant.merchant_info
    end


end
