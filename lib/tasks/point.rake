namespace :point do

  task :add_predefined_point_rules => :environment do
    PointRule::PREDEFINED_RUELS.each do |attri_hash|
      unless PointRule.find_by(name: attri_hash[:name])
        PointRule.create! attri_hash
      end
    end
  end

  task :add_signup_point_to_users do
    signup_point_rule = PointRule.find_by(name: "用户注册")
    User.includes(:point_details).all.each do |u|
      if u.point_details.none? {|p| p.point_rule_id == signup_point_rule.id }
        PointDetail.create_by_user_id_and_rule_name(user_id: user.id, rule_name: "用户注册")
      end
    end
  end

end
