namespace :list do
  task :reset_position => :environment do
    City.all.each do |city|
      city.programs.order("mode").each_with_index do |p, index|
        p.update_column(:position, index + 1)
      end
    end
  end
end
