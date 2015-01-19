class UserCheckIn < ActiveRecord::Base
  belongs_to :user

  after_create :update_user_points, if: "user_id.present?"

  def self.create_if_not_check_in_today_with(user: nil)
    first_check_in = user.user_check_ins.order(created_at: :desc).first
    unless first_check_in &&
        first_check_in.created_at >= Time.zone.now.beginning_of_day &&
        first_check_in.created_at <= Time.zone.now.end_of_day
      user.user_check_ins << UserCheckIn.create
    end
  end

  private
  def update_user_points
    PointDetail.create_by_user_id_and_rule_name(user_id: self.user_id, rule_name: "每日登录")
  end
end
