class PointDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :point_rule

  after_create :update_user_points_and_experience


  private
  def update_user_points_and_experience
    user = self.user
    credit = self.point_rule.credit
    user.points += credit
    user.experience += credit
    user.save
  end

end
