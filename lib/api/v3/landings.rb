# coding:utf-8
module API::V3
  class Landings < Grape::API

    resource :landings do

      params do
        optional :type, type: String
      end
      get :current do
        landings = Landing.where("(start_at <= ? and end_at >= ?) or start_at >= ?", Date.today.beginning_of_day, Date.today.end_of_day, Date.today.end_of_day).all
        present :result, true
        present :message, landings.map{|i| {cover_iphone: i.cover_iphone.url, cover_iphone2x: i.cover_iphone2x.url, cover_iphone586: i.cover_iphone586.url, cover_andriod: i.cover_andriod.url, cover_ipad: i.cover_ipad.url, cover_ipad_retina: i.cover_ipad_retina.url, url: i.url, start_at: i.start_at, end_at: i.end_at } }
      end

    end
  end
end
