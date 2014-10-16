# coding:utf-8
module API::V3
  class Landings < Grape::API

    resource :landings do
      params do
        optional :type, type: String
      end
      get :current do

        present :result, true
        if params[:type] == "bottom_ad"
          landings = BottomAd.current_ad

          present :message, landings.map{|i| {cover: i.cover.url, url: i.url, start_at: i.start_at, end_at: i.end_at } }
        else
          landings = Landing.current_landing

          present :message, landings.map{|i| {cover_iphone: i.cover_iphone.url, cover_iphone2x: i.cover_iphone2x.url, cover_iphone586: i.cover_iphone586.url, cover_andriod: i.cover_andriod.url, cover_ipad: i.cover_ipad.url, cover_ipad_retina: i.cover_ipad_retina.url, url: i.url, start_at: i.start_at, end_at: i.end_at } }

        end

      end
    end
  end
end
