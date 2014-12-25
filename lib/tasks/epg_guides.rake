namespace :epg do
  namespace :guide do
    task :crawl_epg_guides => :environment do
      crawl_epg_guides_from_tvsou
    end

    def crawl_epg_guides_from_tvsou
      #抓取的时候去要后面加上星期几， 如/W4.htm 代表星期四的节目地址
      cctv_url_withour_day_of_week = {
        "CCTV-1" => "http://epg.tvsou.com/programys/TV_1/Channel_1/",
        "CCTV-2" => "http://epg.tvsou.com/programys/TV_1/Channel_3/",
        "CCTV-3" => "http://epg.tvsou.com/programys/TV_1/Channel_4/",
        "CCTV-4" => "http://epg.tvsou.com/programys/TV_1/Channel_5/",
        "CCTV-5" => "http://epg.tvsou.com/programys/TV_1/Channel_6/",
        "CCTV-6" => "http://epg.tvsou.com/programys/TV_1/Channel_7/",
        "CCTV-7" => "http://epg.tvsou.com/programys/TV_1/Channel_8/",
        "CCTV-8" => "http://epg.tvsou.com/programys/TV_1/Channel_9/",
        "CCTV-9" => "http://epg.tvsou.com/programys/TV_1/Channel_10/",
        "CCTV-10" => "http://epg.tvsou.com/programys/TV_1/Channel_11/",
        "CCTV-11" => "http://epg.tvsou.com/programys/TV_1/Channel_12/",
        "CCTV-12" => "http://epg.tvsou.com/programys/TV_1/Channel_13/",
        "CCTV-13" => "http://epg.tvsou.com/programys/TV_1/Channel_14/",
        "CCTV-14" => "http://epg.tvsou.com/programys/TV_1/Channel_15/",
        "CCTV-15" => "http://epg.tvsou.com/programys/TV_1/Channel_16/",
      }

      cctv_url_withour_day_of_week.each do |name, part_url|
        #get guide of today
        get_guide(name: name, url: "#{part_url}W-#{Date.today.days_to_week_start + 1}.htm")
      end
    end

    def get_guide(name:, url:)
      television = Television.where(name: name).first
    end
  end
end
