class Account < ActiveRecord::Base
  has_many :account_signins, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :authentication_keys => [:mobile]

  def email_required?
    false
  end

  def email_changed?
    false
  end

  attr_accessor :verify_code, :signing, :fix_mobile_number

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: 4..18, allow_blank: true
  validates_uniqueness_of :mobile, if: :fix_mobile_number_required?

  validates_presence_of :mobile, :verify_code, on: :create
  validate :verify_code_must_be_in_auth_messages, on: :create

  before_validation :set_password

  def verify_code_must_be_in_auth_messages
    errors.add(:verify_code, "无效的验证码") unless AuthMessage.exists?(verify_code: verify_code, mobile: self.mobile, category: [0,2])
  end

  def set_password
    self.password = self.password_confirmation = self.verify_code if signing
  end

  protected

    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      signing && (!persisted? || !password.nil? || !password_confirmation.nil?)
    end

    def fix_mobile_number_required?
      !fix_mobile_number
    end


end
