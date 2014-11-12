# coding:utf-8
module API::V3
  class Programs < Grape::API
    resource :programs do

      desc "get epg's update time"
      params do
        requires :city_code, type: String
      end
      get :version do
        city = City.find_by(code: params[:city_code])
        if city
          present :result, :true
          present :epg_create_time, city.epg_created_at.to_i
        else
          present :result, false
          present :error_code, 1
          present :message, "can't find city"
        end
      end

      desc "get epg's programs info"
      params do
        requires :city_code, type: String
      end
      get :programs do
        city = City.find_by(code: params[:city_code])
        if city
          programs = city.programs
          present :result, :true
          present :epg_create_time, city.epg_created_at.to_i

          local_programs = city.local_programs
          global_programs = city.global_programs

          present :epg, [
            {branch: "卫视台", programs: global_programs.map {|p| {name: p.name, sid: p.sid, freq: p.freq, logo: p.logo.url, guides: []}}},
            {branch: "地方台", programs: local_programs.map {|p| {name: p.name, sid: p.sid, freq: p.freq, logo: p.logo.url, guides: []}}}
          ]
        end
      end

    end
  end
end
