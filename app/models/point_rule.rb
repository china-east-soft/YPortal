class PointRule < ActiveRecord::Base
  validates_presence_of :name, :credit
  validates_uniqueness_of :name
  validates :credit, :numericality => { :greater_than_or_equal_to => 0 }

  after_commit :flush_cache

  PREDEFINED_RUELS = [{name: "每日登录", desc: "每天签到奖励积分", credit: 5},
                      {name: "节目评论", desc: "看电视发表评论奖励积分", credit: 1},
                      {name: "发帖", desc: "社区发布帖子", credit: 10}
                     ]
  PREDEFINED_RULE_NAMES = PREDEFINED_RUELS.map {|h| h[:name] }

  private
  def flush_cache
    Rails.cache.delete("pointrule:name:#{self.name}")
  end
end
