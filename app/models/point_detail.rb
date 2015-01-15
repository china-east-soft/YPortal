class PointDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :point_rule

  after_create :update_user_points_and_experience

  def self.create_by_user_id_and_rule_name(user_id:, rule_name:)
    rule = Rails.cache.fetch("pointrule:name:#{rule_name}") do
      PointRule.where(name: rule_name).first
    end

    if rule
      user = User.find user_id

      if rule_name == "节目评论"
        point_details = user.point_details.includes(:point_rule).where("created_at > ? and created_at < ?", Time.now.beginning_of_day, Time.now.end_of_day)
        unless point_details.select {|p| p.point_rule.name == "节目评论"}.inject(0) {|points, p| points + p.point_rule.credit } >= 10
          PointDetail.create(user_id: user_id, point_rule_id: rule.id)
        end
      else
        PointDetail.create(user_id: user_id, point_rule_id: rule.id)
      end
    end
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
