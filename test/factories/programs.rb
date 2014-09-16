FactoryGirl.define do
  factory :program do
    sequence(:channel, 1000) {|n| "CMMB#1#{n}#2#{n}#杭州"}
    sequence(:name, 20) {|n| "cctv-#{n}"}
  end
end
