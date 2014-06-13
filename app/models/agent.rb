class Agent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :not_required_password
  def password_required?
    super unless self.not_required_password
  end

  has_one :agent_info, dependent: :destroy
  accepts_nested_attributes_for :agent_info

  has_many :merchants, dependent: :nullify
  has_many :terminals, dependent: :nullify

end
