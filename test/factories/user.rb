FactoryGirl.define do
  factory(:user) do
    name "kkk"
    sequence(:mobile_number, 0) {|n|
      if n <= 9
        "1234567890#{n}"
      elsif n <= 99
        "123456789#{n}"
      end
    }
    password "12345"
    password_confirmation "12345"
  end
end
