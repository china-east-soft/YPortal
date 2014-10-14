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
          landing = BottomAd.current_ad.first
          if landing
            msg = {
                    cover: landing.cover.url,
                    url: landing.url,
                    start_at: landing.start_at,
                    end_at: landing.end_at
                  }

            present :message, [msg]
          else
            present :message, []
          end
        else
          landing = Landing.current_landing.first
          if landing
            present :message, [{
                              cover_iphone: landing.cover_iphone.url,
                              cover_iphone2x: landing.cover_iphone2x.url,
                              cover_iphone586: landing.cover_iphone586.url,
                              cover_andriod: landing.cover_andriod.url,
                              cover_ipad: landing.cover_ipad.url,
                              cover_ipad_retina: landing.cover_ipad_retina.url,
                              url: landing.url, start_at: landing.start_at, end_at: landing.end_at
                            }]
          else
            present :message, []
          end
        end

      end
    end
  end
end
