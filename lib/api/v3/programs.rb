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
          present :result, :true
          present :epg_create_time, city.epg_created_at.to_i
          present :enable_branch, city.enable_branch?

          branchs = Television.pluck(:branch).uniq
          epg = branchs.map do |b|
            {branch: b, programs: city.programs_by_branch(b).map {|p| {program_id: p.id, name: p.name || "", sid: p.sid || "", freq: p.freq || "", logo: p.logo.url}}}
          end

          present :epg, epg
          present :epg_guides_file_url, "http://#{Rails.application.config.default_url_options[:host]}/cities/#{city.epg_guides_file}"
        else
          present :result, false
          present :error_code, 1
          present :message, "未找到所属城市"
        end
      end

      desc "get epg's programs guides info"
      params do
        requires :city_code, type: String
      end
      get :epg_guides do
        city = City.find_by(code: params[:city_code])
        if city

          present :result, :true
          present :guides, city.epg_guides
        else
          present :result, false
          present :error_code, 1
          present :message, "未找到所属城市"
        end
      end
    end
  end
end
