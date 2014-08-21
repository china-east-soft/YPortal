class Agent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope {order "id"}

  before_destroy :re_allcoate_merchants_to_yunlian

  attr_accessor :not_required_password
  def password_required?
    super unless self.not_required_password
  end

  has_one :agent_info, dependent: :destroy
  accepts_nested_attributes_for :agent_info

  has_many :merchants
  has_many :terminals

  def active
    agent_info.update_column :status, AgentInfo.statuses[:active]

    password = SecureRandom.hex 4
    self.password = password
    self.password_confirmation = password
    self.save

    AgentMailer.delay.active_after_registration(self.id, password)
  end

  def yunlian?
    id == 0
  end


  private
  def re_allcoate_merchants_to_yunlian
    self.merchants.update_all(agent_id: 0)
    self.terminals.update_all(agent_id: 0)
  end

end
