class Merchant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  has_one :merchant_info, dependent: :destroy
  accepts_nested_attributes_for :merchant_info

  has_one :portal_style, dependent: :destroy

  has_many :products, dependent: :destroy

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: 8..18, allow_blank: true

  validates_presence_of :mobile, :verify_code, :mid, on: :create

  validate :mid_must_be_in_terminals

  def mid_must_be_in_terminals
    errors.add(:mid, "无效的mid") unless Terminal.exists?(mid: mid, status: AuthToken.statuses[:init])
  end

  after_create :get_terminal

  attr_accessor :verify_code, :mid

  has_many :terminals, dependent: :nullify

  protected

    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end


    def get_terminal
      Terminal.where(mid: self.mid, status: AuthToken.statuses[:init], merchant_id: nil).update_all(merchant_id: self.id, status: AuthToken.statuses[:active])
    end


end
