class Agent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create do |agent|
    agent.build_agent_info.save
  end

  has_one :agent_info, dependent: :destroy
  accepts_nested_attributes_for :agent_info

  has_many :merchants, dependent: :nullify
  has_many :terminals, dependent: :nullify

end
