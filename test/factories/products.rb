FactoryGirl.define do
  factory :product do
    # merchant

    name 'name'
    price 100
    description "test"
    product_photo_file_name "test.png"
    product_photo_content_type "image"
    product_photo_file_size "10k"
    product_photo_updated_at Time.now

  end
end

