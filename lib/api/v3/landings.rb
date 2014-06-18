# coding:utf-8
module API::V3
  class Landings < Grape::API

    resource :landings do
      
      get :current do
        landings = Landing.where("(start_at <= ? and end_at >= ?) or start_at >= ?", Date.today.beginning_of_day, Date.today.end_of_day, Date.today.end_of_day).all
        present :result, true
        present :message, landings.map{|i| {cover: i.cover.url, url: i.url, start_at: i.start_at, end_at: i.end_at } }
      end

    end
  end
end