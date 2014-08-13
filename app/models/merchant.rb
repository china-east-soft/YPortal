class Merchant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :authentication_keys => [:mobile]

  after_create do |merchant|
    unless merchant.agent_id
      merchant.agent_id = 0
      merchant.save
    end
  end

  after_save do |merchant|
    if merchant.agent_id
      merchant.terminals.update_all agent_id: merchant.agent_id
    end
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  has_many :auth_tokens, dependent: :destroy

  has_one :merchant_info, dependent: :destroy
  accepts_nested_attributes_for :merchant_info

  has_many :portal_styles, dependent: :destroy
  has_many :banners, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :products, dependent: :destroy

  belongs_to :agent

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: 8..18, allow_blank: true
  validates_uniqueness_of :mobile

  validates_presence_of :mobile, :verify_code, :mid, on: :create, unless: :add_by_admin

  validate :mid_must_be_in_terminals, on: :create
  validate :verify_code_must_be_in_auth_messages, on: :create, unless: :add_by_admin

  def mid_must_be_in_terminals
    errors.add(:mid, "无效的mid") unless Terminal.exists?(mid: mid, status: Terminal.statuses[:init])
  end

  def current_portal_style
    self.portal_styles.where(current: true).first
  end

  def verify_code_must_be_in_auth_messages
    errors.add(:verify_code, "无效的验证码") unless AuthMessage.exists?(verify_code: verify_code, category: 0)
  end

  after_create :get_terminal, :get_portal_style

  attr_accessor :verify_code, :mid, :add_by_admin

  has_many :terminals, dependent: :nullify

  def get_portal_style
    foo = PortalStyle.where(merchant_id: self.id, layout: "默认一").first_or_create
    bar = PortalStyle.where(merchant_id: self.id, layout: "默认二").first_or_create
    unless self.current_portal_style
      foo.update_column(:current, true)
    end
  end

  protected

    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end


    #todo what that do?
    def get_terminal
      Terminal.where(mid: self.mid, status: AuthToken.statuses[:init], merchant_id: nil).
        all.each do |terminal|
          terminal.active self.id
        end
        # update_all(merchant_id: self.id, agent_id: agent_id, status: AuthToken.statuses[:active], added_by_merchant_at: Time.now)
    end

end
