FactoryGirl.define do
  factory(:comment) do
    mac "b8:70:f4:03:43:06"
    channel "cctv-1"
    body "good program!"

    factory :comment_of_program do
      program
    end
  end
end
