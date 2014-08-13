class FeedBack < ActiveRecord::Base

  default_scope { order("created_at desc") }

  validates_presence_of :content

end
