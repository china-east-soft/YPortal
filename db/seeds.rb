# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

#第0个记录是默认为云链
unless Agent.find_by_id(0)
  yunlian = Agent.new
  yunlian.id = 0
  yunlian.email = "service@cloudchain.cn"
  yunlian.password = "12345678"
  yunlian.password_confirmation = "12345678"

  if yunlian.save
    yunlian.build_agent_info(category: 2, name: "云链", industry: "Test", city: "杭州", contact: "yunlian", telephone: "123456789").save
  end
end
