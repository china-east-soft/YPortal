class Watching < ActiveRecord::Base
  belongs_to :program
  belongs_to :user

  after_create :update_user_point

  private
  def update_user_point
    if user
      user.remain_watch_seconds += self.seconds

      #一个小时10分
      while user.remain_watch_seconds >= 3600
        PointDetail.create_by_user_id_and_rule_name(user_id: user.id, rule_name: "看电视达一小时")
        user.remain_watch_seconds -= 3600
      end

      user.save!
    end
  end
end
