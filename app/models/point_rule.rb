class PointRule < ActiveRecord::Base
  validates_presence_of :name, :credit
  validates_uniqueness_of :name
  validates :credit, :numericality => { :greater_than_or_equal_to => 0 }

  after_commit :flush_cache

  PREDEFINED_RUELS = [{name: "用户注册", desc: "用户首次注册", credit: 1000},
                      {name: "每日登录", desc: "每天签到奖励积分", credit: 5},
                      {name: "看电视达一小时", desc: "使用APP就累计", credit: 10},
                      {name: "节目评论", desc: "看电视发表评论奖励积分", credit: 1},
                      {name: "微论坛发帖", desc: "社区发布帖子", credit: 10},
                      {name: "分享社交论坛", desc: "分享到微博等", credit: 10},
                     ]
  PREDEFINED_RULE_NAMES = PREDEFINED_RUELS.map {|h| h[:name] }

  private
  def flush_cache
    Rails.cache.delete("pointrule:name:#{self.name}")
  end
end
