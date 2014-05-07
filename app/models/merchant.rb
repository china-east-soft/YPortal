class Merchant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :merchant_info, dependent: :destroy
  accepts_nested_attributes_for :merchant_info

  has_many :terminals, dependent: :nullify

end
