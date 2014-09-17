class Program < ActiveRecord::Base
  has_many :comments, dependent: :destroy

  after_save :update_comments_channel

  #channel 四个字段唯一确定一个节目, 形式如： CMMB#12#28#杭州
  CHANNEL_FORMAT = /\A\w+\-(\d+\-){2}\p{Word}+\Z/u
  validates :channel, presence: true, uniqueness: true, format: {with: CHANNEL_FORMAT,
                                                                  message: "格式错误！"}
  validates_presence_of :name


  private
  def update_comments_channel
    comments.update_all channel: channel
  end
end
