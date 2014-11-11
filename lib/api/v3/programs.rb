# coding:utf-8
module API::V3
  class Comments < Grape::API
    resources :programs do
      desc "get epg's update time"
      params do
        require :city_code, type: String
      end
      get :version do
        city = City.find_by(code: params[:city_code])
        if city
          present :result, :true
          present :epg_create_time, Time.now  #TODO
        else
          present :result, false
          present :error_code, 1
          present :message, "can't find city"
        end
      end

      desc "get epg's programs info"
      params do
        require :city_code, type: String
      end
      get :programs do
        city = City.find_by(code: params[:city_code])
        if city
          programs = city.programs
          present :result, :true
          present :epg_create_time, Time.now #todo
          present :epg, programs.map {|p| p.name, p.logo.try(:url) }
        end
      end

    end
  end
end
