class PointDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :point_rule

  after_create :update_user_points_and_experience

  def self.create_by_user_id_and_rule_name(user_id:, rule_name:)
    rule = PointRule.find_by(name: rule_name)
    PointDetail.create(user_id: user_id, point_rule_id: rule.id)
  end


  private
  def update_user_points_and_experience
    user = self.user
    credit = self.point_rule.credit
    user.points += credit
    user.experience += credit
    user.save
  end

end
