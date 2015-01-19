#require 'nokogiri'

namespace :epg do
  namespace :guide do

    task :crawl_epg_guides => :environment do
      # crawl_epg_guides_from_tvsou
      crawl_epg_guides_from_tvmao
    end

    task :generate_city_epg_guides_files => :environment do
      City.all.each do |city|
        dir = "#{Rails.root.to_s}/public/cities"
        unless File.exists? dir
          mkdir_p dir
        end

        File.open("#{Rails.root.to_s}/public/cities/#{city.id}.json", "w") do |f|
          guides = city.programs.includes(:television).map {|p| {program_id: p.id, program_name: p.name || "", guides: p.guides}}
          f.write(guides.to_json)
          city.touch(:epg_guide_created_at)
        end
      end
    end

    task :generate => [:environment, :crawl_epg_guides, :generate_city_epg_guides_files] do
    end


    def crawl_epg_guides_from_tvsou
      #抓取的时候去要后面加上星期几， 如/W4.htm 代表星期四的节目地址
      cctv_url = {
        "CCTV-1" => "http://epg.tvsou.com/programys/TV_1/Channel_1/",
        # "CCTV-2" => "http://epg.tvsou.com/programys/TV_1/Channel_3/",
        # "CCTV-3" => "http://epg.tvsou.com/programys/TV_1/Channel_4/",
        # "CCTV-4" => "http://epg.tvsou.com/programys/TV_1/Channel_5/",
        # "CCTV-5" => "http://epg.tvsou.com/programys/TV_1/Channel_6/",
        # "CCTV-6" => "http://epg.tvsou.com/programys/TV_1/Channel_7/",
        # "CCTV-7" => "http://epg.tvsou.com/programys/TV_1/Channel_8/",
        # "CCTV-8" => "http://epg.tvsou.com/programys/TV_1/Channel_9/",
        # "CCTV-9" => "http://epg.tvsou.com/programys/TV_1/Channel_10/",
        # "CCTV-10" => "http://epg.tvsou.com/programys/TV_1/Channel_11/",
        # "CCTV-11" => "http://epg.tvsou.com/programys/TV_1/Channel_12/",
        # "CCTV-12" => "http://epg.tvsou.com/programys/TV_1/Channel_13/",
        # "CCTV-13" => "http://epg.tvsou.com/programys/TV_1/Channel_14/",
        # "CCTV-14" => "http://epg.tvsou.com/programys/TV_1/Channel_15/",
        # "CCTV-15" => "http://epg.tvsou.com/programys/TV_1/Channel_16/",
      }

      cctv_url.each do |name, part_url|
        #get guide of today
        guides = get_guide(name: name, url: "#{part_url}W#{Date.today.days_to_week_start + 1}.htm")
        p guides
      end
    end

    def get_guide_from_tvsou(name:, url:)
      begin
        puts "get_guide: #{name}, #{url}"
        television = Television.where(name: name).first
        page = Nokogiri::HTML(open(url), nil, 'gbk')

        if television
          # (page.css('#PMT1')+page.css('#PMT2')).each do |item|
          (page.css("#PMT1") + page.css("#PMT2")).map do |item|
            p item.text
            guide = {}
            guide[:name] = item.at('a.black').content
            guide[:start] = Time.now.strftime("%Y-%m-%d ") + item.at('font').content.strip + ":00"
          end
        else
          p "no #{name} in database"
        end
      rescue Exception => e
        p e
      end
    end

    def crawl_epg_guides_from_tvmao
      #抓取的时候要更换最后面的数字， 如w4.htm代表星期四的节目地址
      cctv_url = {
        "CCTV-1" => "http://www.tvmao.com/program/CCTV-CCTV1-w1.html",
        "CCTV-2" => "http://www.tvmao.com/program/CCTV-CCTV2-w1.html",
        "CCTV-3" => "http://www.tvmao.com/program/CCTV-CCTV3-w1.html",
        "CCTV-4" => "http://www.tvmao.com/program/CCTV-CCTV4-w1.html",
        "CCTV-5" => "http://www.tvmao.com/program/CCTV-CCTV5-w1.html",
        "CCTV-6" => "http://www.tvmao.com/program/CCTV-CCTV6-w1.html",
        "CCTV-7" => "http://www.tvmao.com/program/CCTV-CCTV7-w1.html",
        "CCTV-8" => "http://www.tvmao.com/program/CCTV-CCTV8-w1.html",
        "CCTV-9" => "http://www.tvmao.com/program/CCTV-CCTV9-w1.html",
        "CCTV-10" => "http://www.tvmao.com/program/CCTV-CCTV10-w1.html",
        "CCTV-11" => "http://www.tvmao.com/program/CCTV-CCTV11-w1.html",
        "CCTV-12" => "http://www.tvmao.com/program/CCTV-CCTV12-w1.html",
        "CCTV-13" => "http://www.tvmao.com/program/CCTV-CCTV13-w1.html",
        "CCTV-14" => "http://www.tvmao.com/program/CCTV-CCTV15-w1.html",
        "CCTV-15" => "http://www.tvmao.com/program/CCTV-CCTV16-w1.html",
      }

      cctv_url.each do |name, url|
        get_week_guides_from_tvmao(name: name, monday_url: url)
      end

      #获得卫视的电台列表并根据电台列表抓取epg guide信息
      url_anhuiweishi = "http://www.tvmao.com/program_satellite/AHTV1-w1.html"
      page = Nokogiri::HTML(open(url_anhuiweishi))
      page.css("div.chlsnav ul.r li").each do |li_telivision|
        a = li_telivision.at_css("a")
        if a
          weishi_url = "http://www.tvmao.com" + a["href"]
          telivision_name = a["title"]

          get_week_guides_from_tvmao(name: telivision_name, monday_url: weishi_url)
        end
      end
    end

    def get_week_guides_from_tvmao(name: name, monday_url: url)
      television = Television.where(name: name).first

      unless television
        # p "no #{name} in database"
        return
      end

      monday_of_this_week = Time.now.beginning_of_week
      guides = {}

      7.times do |i|
        time = monday_of_this_week + i.day

        url = monday_url.sub("w1", "w#{i + 1}")

        guide = get_day_guide_from_tvmao(name: name, url: url, time_of_guide: time)
        guides[(i + 1)] = guide
      end

      File.open("#{Rails.root.to_s}/public/guides/#{television.id}.json", "w") do |f|
        f.write(guides.to_json)
      end
    end

    def get_day_guide_from_tvmao(name:, url:, time_of_guide: Time.now)
      begin
        puts "get_guide: #{name}, #{url}"
        page = Nokogiri::HTML(open(url))

        page.css("#pgrow li").map do |item|
          if item["id"]
            next
          end

          guide = {}

          span_time = item.at_css("span")
          time =  span_time.text

          guide[:start] = time_of_guide.strftime("%Y-%m-%d ")+ time.strip + ":00"

          #获取节目名称
          if item.at_css("a.drama")
            match = item.text.match(/(?<=#{time})\s+[\p{Word}:]+\/\d+/u)
          else
            match = item.text.match(/(?<=#{time})\s+[\p{Word}:]+/u)
          end

          if match
            guide[:name] = match[0]
          else
            next
          end
          guide
        end.compact
      rescue Exception => e
        puts e
        nil
      end
    end

  end
end
