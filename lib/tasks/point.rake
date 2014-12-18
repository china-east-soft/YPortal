namespace :point do

  task :add_predefined_point_rules => :environment do
    PointRule::PREDEFINED_RUELS.each do |attri_hash|
      unless PointRule.find_by(name: attri_hash[:name])
        PointRule.create! attri_hash
      end
    end
  end

end
