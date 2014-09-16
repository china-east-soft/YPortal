class Program < ActiveRecord::Base
  has_many :comments, dependent: :destroy

  #channel 四个字段唯一确定一个节目, 形式如： CMMB#12#28#杭州
  CHANNEL_FORMAT = /\A\w+#(\d+#){2}\p{Word}+\Z/u
  validates :channel, presence: true, format: {with: CHANNEL_FORMAT}

  validates_presence_of :name
end
