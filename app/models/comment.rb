class Comment < ActiveRecord::Base

  validates_presence_of :mac, :channel, :body, alloc_blank: false

  default_scope { order(id: :desc) }

  def self.comments_for_app(channel:, id: 0, limit: 20)
    #id == 0 present request for the newest record
    if id == 0
      where(channel: channel).limit(limit)
    else
      where("channel = :channel AND id < :id", {channel: channel, id: id}).limit(limit)
    end
  end

end