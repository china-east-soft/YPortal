class AppAccount < ActiveRecord::Base
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

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: 6..18, allow_blank: true

  validates_presence_of :mobile, :verify_code, on: :create

  attr_accessor :verify_code

  validate :verify_code_must_be_in_auth_messages, on: :create

  def verify_code_must_be_in_auth_messages
    errors.add(:verify_code, "无效的验证码") unless AuthMessage.exists?(verify_code: verify_code, category: 2)
  end

  protected

    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end


end