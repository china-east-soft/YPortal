class Wifi::SurroundingsController < WifiController

  before_action :set_merchant_info

  def index
    
    @merchant_infos = MerchantInfo.all

    @distances = ["全部距离","100 m","500 m","1 km","5 km"]
    @industries = ["全部分类"] + MerchantInfo.uniq.pluck('industry').compact
    @order_bys = %w{ 默认排序 距离最近 }

  end

  def load
    @merchant_infos = MerchantInfo
    if params[:distance] != '全部距离'
      distance, units = params[:distance].split(' ')
      sym_unit = case units
      when "km" then :km
      when "m" then :mi
      end
      @merchant_infos = MerchantInfo.near([@merchant_info.shop_latitude, @merchant_info.shop_longitude], distance.to_i, units: sym_unit)
    end
    @merchant_infos = @merchant_infos.where(industry: params[:industry]) if params[:industry] != '全部分类'
    @merchant_infos = @merchant_infos.all
  end

  private

    def set_merchant_info
      @merchant_info = terminal_merchant.merchant_info
    end


end
