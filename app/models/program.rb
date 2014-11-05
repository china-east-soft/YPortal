class Program < ActiveRecord::Base
  has_many :comments, dependent: :destroy

  before_validation :channel_to_upper_and_generate_mod_freq_name_and_location
  after_save :update_comments_channel

  #channel 四个字段唯一确定一个节目, 形式如： CMMB-12-28-杭州(mod-feq-sid-location)
  #CHANNEL_FORMAT = /\A\w+\-(\d+\-){2}(\p{Word}|\*)+\Z/u

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

  scope :global_programs, lambda { where(mode: "CMMB", channel_name: CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.keys) }
  # scope :local_programs, lambda { where("mode != 'CMMB' or (mode = 'CMMB' and name NOT IN (#{CMMB_GLOBAL_PROGRAMS.keys.join(",")}))") }
  scope :local_programs, lambda {where("mode != 'CMMB' or ((mode = 'CMMB') and (channel_name NOT IN ('CCTV-1', 'CCTV-5', 'CCTV-13','晴彩电影','晴彩天下')))")}

  # scope :local_programs, lambda { where("SELECT * FROM programs WHERE mode != 'CMMB' or (mode = 'CMMB' and sid NOT IN (601, 602, 603, 604, 605))") }
  validates :channel, presence: true, uniqueness: true, format: {with: CHANNEL_FORMAT,
                                                                  message: "格式错误！"}
  validates_presence_of :name, :mode, :freq, :channel_name, :location, allow_blank: false

  #step1: 首先根据channel查找节目， 若存在则返回节目
  #step2: 根据mode和名字查找CMMB的固定节目, 不存在则新建CMMB的固定节目
  #setp3: 创建新节目
  def self.find_or_create_by_channel(channel)
    channel.upcase!

    program = Program.find_by(channel: channel)

    if program.nil?
      mode, freq, name_from_channel, location = channel.split('@')
      channel_name = Program.name_to_channel_name(name_from_channel)

      if mode == 'CMMB' && CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.keys.include?(channel_name)
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
    end

    program
  end

  def self.find_by_channel(channel)
    channel.upcase!

    program = Program.find_by(channel: channel)
    if program.nil?
      mode, freq, channel_name, location = channel.split('@')
      if mode == 'CMMB' && CMMB_CHANNEL_NAME_GLOBAL_PROGRAMS.values.flatten.include?(channel_name)
        name = Program.name_to_channel_name(channel_name)
        program = Program.where(mode: 'CMMB', channel_name: name).first
      end
    end

    program
  end

  def parent_comments_in_4_hour_for_app(id: 0, limit: 20)
    #id == 0 present request for the newest record
    if id == 0
      comments.includes(:user, :children).where(parent_id: nil).where("created_at >= ?", Time.now - 4.hour).order(id: :desc).limit(limit)
    else
      comments.includes(:user, :children).where(parent_id: nil).where("created_at >= ?", Time.now - 4.hour).order(id: :desc).where("id < :id", {id: id}).limit(limit)
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

end
