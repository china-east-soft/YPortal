class User < ActiveRecord::Base

  has_many :comments

  has_secure_password

  validates :mobile_number, uniqueness: true, presence: true, format: {with: /\A\d{11}\z/}
  validates :name, presence: true

end
