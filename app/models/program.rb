class Program < ActiveRecord::Base
  has_many :comments, dependent: :destroy

  before_validation :generate_mod_freq_sid_and_location_accord_to_channel
  after_save :update_comments_channel


  scope :global_programs, lambda { where(mode: "CMMB", sid: CMMB_SID_GLOBAL_PROGRAMS.keys) }
  scope :local_programs, lambda { where("mode != 'CMMB' or (mode = 'CMMB' and sid NOT IN (601, 602, 603, 604, 605))") }
  # scope :local_programs, lambda { where("SELECT * FROM programs WHERE mode != 'CMMB' or (mode = 'CMMB' and sid NOT IN (601, 602, 603, 604, 605))") }

  #channel 四个字段唯一确定一个节目, 形式如： CMMB-12-28-杭州(mod-feq-sid-location)
  CHANNEL_FORMAT = /\A\w+\-(\d+\-){2}(\p{Word}|\*)+\Z/u

  CMMB_SID_GLOBAL_PROGRAMS = { "601" => "cctv-1", "602" => "晴彩电影", "603" => "cctv-5",
                               "604" => "晴彩天下", "605" => "cctv-13"}

  validates :channel, presence: true, uniqueness: true, format: {with: CHANNEL_FORMAT,
                                                                  message: "格式错误！"}
  validates_presence_of :name, :mode, :freq, :sid, :location, allow_blank: false

  #step1: 首先根据channel查找节目， 若存在则返回节目
  #step2: 根据mode和sid查找CMMB的固定节目, 不存在则新建CMMB的固定节目
  #setp3: 创建新节目
  def self.find_or_create_by_channel(channel)

    program = Program.find_by(channel: channel)

    if program.nil?
      mode, freq, sid, location = channel.split('-')
      #601-602表示固定节目
      if mode == 'CMMB' && sid =~ /^60[0-6]$/
        program = Program.where(mode: 'CMMB', sid: sid).first
        if program.nil?
          program = Program.create(
                                    channel: "CMMB-00-#{sid}-*",
                                    name: CMMB_SID_GLOBAL_PROGRAMS[sid]
                                  )
        end
      else
        program = Program.create(channel: channel, name: location)
      end
    end

    program
  end

  def self.find_by_channel(channel)
    program = Program.find_by(channel: channel)
    if program.nil?
      mode, freq, sid, location = channel.split('-')
      #601-602表示固定节目
      if mode == 'CMMB' && sid =~ /^60[0-6]$/
        program = Program.where(mode: 'CMMB', sid: sid).first
      end
    end

    program
  end

  def comments_in_4_hour_for_app(id: 0, limit: 20)
    #id == 0 present request for the newest record
    if id == 0
      comments.includes(:user).where("created_at >= ?", Time.now - 4.hour).order(id: :desc).limit(limit)
    else
      comments.includes(:user).where("created_at >= ?", Time.now - 4.hour).order(id: :desc).where("id < :id", {id: id}).limit(limit)
    end
  end


  private
  def update_comments_channel
    comments.update_all channel: channel
  end

  def generate_mod_freq_sid_and_location_accord_to_channel
    mode, freq, sid, location = channel.split('-')
    self.mode = mode
    self.freq = freq
    self.sid = sid
    self.location = location
  end

end
