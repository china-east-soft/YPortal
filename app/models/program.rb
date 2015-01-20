class Program < ActiveRecord::Base
  self.table_name  = 'programs'
  has_many :comments, dependent: :destroy

  has_many :users

  belongs_to :television
  belongs_to :city, counter_cache: true
  acts_as_list scope: [:city, :branch]

  before_validation :channel_to_upper_and_generate_mod_freq_name_and_location, if: "self.channel.present?"

  # default_scope { order(mode: :asc) }

  after_save :update_city_epg_crated_at, if: "city_id.present?"
  after_destroy :update_city_epg_crated_at, if: "city_id.present?"

  before_create :set_branch_to_television_branch, if: "television_id.present?"
  before_create :set_position_to_last, if: "city.present?"

  after_destroy :update_comments_channel, if: "city_id.present?"
  after_commit :flush_cache

  # after_save :update_comments_channel

  delegate :logo, to: :television

  # change channel format to : CMMB@123@CCTV综合@杭州(mod-freq-name-location)
  CHANNEL_FORMAT = /\A\w+@(\d+)@(.*)@(.*)\Z/u
  CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS = {
                                       "CCTV-1" => ["CCTV-1", "CCTV1", "CCTV综合", "CCTV-综合"],
                                       "睛彩电影" => ["睛彩电影"],
                                       "CCTV-5"  => ["CCTV-5", "CCTV5", "CCTV体育", "CCTV-体育"],
                                       "睛彩天下" => ["睛彩天下"],
                                       "CCTV-13" => ["CCTV-13", "CCTV13", "CCTV新闻", "CCTV-新闻"]
                                      }
  def self.name_to_channel_name(name)
    CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.each do |key, value|
      if value.include? name
        return key
      end
    end

    return name
  end

  scope :global_programs, lambda { includes(:city, :television).where(mode: "CMMB", channel_name: CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.keys) }

  scope :local_programs, lambda { includes(:city, :television).where("((mode = 'CMMB') and (channel_name NOT IN ('CCTV-1', 'CCTV-5', 'CCTV-13','睛彩电影','睛彩天下')))")}

  # validates :channel, presence: true, uniqueness: true, format: {with: CHANNEL_FORMAT,                                                                  message: "格式错误！"}

  validates_presence_of :name, :mode, :freq, allow_blank: false
  validates_presence_of :television_id, if: "city.present?"


  class << self
    #step1: 首先根据channel查找节目， 若存在则返回节目
    #step2: 根据mode和名字查找CMMB的固定节目, 不存在则新建CMMB的固定节目
    #setp3: 创建新节目
    def find_or_create_by_channel(channel)
      channel.upcase!
      Rails.cache.fetch("program:channel:#{channel}") do
        find_or_create_by_channel_to_cache(channel)
      end
    end

    def find_or_create_by_channel_to_cache(channel)
      program = Program.find_by(channel: channel)

      if program.nil?
        mode, freq, name_from_channel, city_code = channel.split('@')
        channel_name = Program.name_to_channel_name(name_from_channel)

        if mode == 'CMMB'
          if CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.keys.include?(channel_name)
            program = Program.where(mode: 'CMMB', channel_name: channel_name).first
            if program.nil?
              program = Program.create(
                channel: "CMMB@00@#{channel_name}@*",
                name: channel_name
              )
            end
          else
            program = Program.create(channel: channel, name: channel_name)
          end
        else #mode != CMMB
          city = City.find_by code: city_code
          program = city.programs.where(mode: mode, name: name_from_channel, freq: freq).first
        end
      end

      program
    end

    def find_by_channel(channel)
      channel.upcase!

      program = Program.find_by(channel: channel)
      if program.nil?
        mode, freq, name_from_channel, city_code = channel.split('@')
        if mode == 'CMMB' && CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.values.flatten.include?(channel_name)
          name = Program.name_to_channel_name(channel_name)
          program = Program.where(mode: 'CMMB', channel_name: name).first
        else #mode != CMMB
          city = City.find_by code: city_code
          program = city.programs.where(mode: mode, name: name_from_channel, freq: freq).first
        end
      end

      program
    end
  end


  def parent_comments_in_4_hour_for_app(id: 0, limit: 20)
    #id == 0 present request for the newest record
    if id == 0
      comments.includes(:user, :children).where(parent_id: nil).where("created_at >= ?", Time.now - 4.hour).order(id: :desc).limit(limit)
    else
      comments.includes(:user, :children).where(parent_id: nil).where("created_at >= ?", Time.now - 4.hour).order(id: :desc).where("id < :id", {id: id}).limit(limit)
    end
  end


  def guides
    @guides ||=  if television_id
                   if File.exist?("#{Rails.root.to_s}/public/guides/#{television_id}.json")
                     File.open("#{Rails.root.to_s}/public/guides/#{television_id}.json", 'r') do |f|
                       JSON.parse(f.read)
                     end
                   end
                 end
  end

  def guide_now
    if guides
      day_of_week = Time.now.days_to_week_start + 1
      guides_today = guides[day_of_week.to_s]
      current = Time.now
      guides_today.select do |h|
        t = Time.parse(h["start"])
        t <= current
      end.last
    end
  end


  private
  def update_comments_channel
    comments.update_all channel: channel
  end

  def channel_to_upper_and_generate_mod_freq_name_and_location
    #channel.upcase! not work,  not konw the reason now.
    self.channel = self.channel.upcase

    mode, freq, channel_name, location = channel.split('@')
    self.mode = mode
    self.freq = freq
    self.channel_name = channel_name
    self.location = location
  end

  def update_city_epg_crated_at
    city.try(:touch, :epg_created_at)
  end

  def flush_cache
    Rails.cache.delete_matched("program:channel:*")
  end

  def set_branch_to_television_branch
    self.branch = television.branch
  end

  def set_position_to_last
    self.position = (city.programs_by_branch(self.branch).maximum("position") || 0) + 1
  end

end
