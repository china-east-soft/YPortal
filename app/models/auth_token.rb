class AuthToken < ActiveRecord::Base
  enum status: [ :init, :active, :expired ] 

  belongs_to :account
  belongs_to :terminal
  belongs_to :merchant

  validates_uniqueness_of :client_identifier, scope: :mac, conditions: -> { where(status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]) }
  scope :actived, lambda { |merchant| where(status: AuthToken.statuses[:active]) }

  class << self
    def update_expired_status(mac)
      AuthToken.where(mac: mac, status: 1).where(["expired_timestamp < :expired_timestamp", { expired_timestamp: Time.now.to_i }]).update_all(status: 2)
    end
  end

  def update_status
    if self.expired_timestamp.present? && self.active? && self.expired_timestamp.to_i < Time.now.to_i
      self.update_columns(status: AuthToken.statuses[:expired])
    end
  end

end
