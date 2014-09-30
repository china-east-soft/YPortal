FactoryGirl.define do
  factory(:user) do
    name "kkk"
    sequence(:mobile_number, 0) {|n| "1234567890#{n}"}
    password "12345"
    password_confirmation "12345"
  end
end
