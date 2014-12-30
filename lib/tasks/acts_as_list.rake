namespace :list do
  task :reset_position => :environment do
    branches = Television.pluck(:branch).uniq

    City.all.each do |city|
      branches.each do |branch|
        city.programs_by_branch(branch).order("mode").each_with_index do |p, index|
          p.update_column(:position, index + 1)
        end
      end
    end
  end
end
