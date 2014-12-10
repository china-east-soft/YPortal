class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates_presence_of :follower_id, :followed_id

  #状态， 单向关注， 相互关注， 拉黑
  enum status: [:unidirection, :bidirectional, :block]
end
