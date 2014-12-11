class Blacklist < ActiveRecord::Base
  belongs_to :blocker, class_name: "User"
  belongs_to :blocked, class_name: "User"

  validates_presence_of :blocker_id, :blocked_id
end
