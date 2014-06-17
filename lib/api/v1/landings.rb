# coding:utf-8
module API::V1
  class Landings < Grape::API

    resource :landings do
      
      get :current do
        landing = Landing.where("start_at <= ? and end_at >= ?", Date.today.beginning_of_day, Date.today.end_of_day).first
        present { cover: landing.cover.url, url: cover.url } if landing
      end

    end
  end
end