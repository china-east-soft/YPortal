class AuthToken < ActiveRecord::Base

  include Communicate

  enum status: [ :init, :active, :expired ] 

  belongs_to :account
  belongs_to :terminal
  belongs_to :merchant

  validates_uniqueness_of :client_identifier, scope: :mac, conditions: -> { where(status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]) }
  scope :actived, lambda { |merchant_id| where(status: AuthToken.statuses[:active], merchant_id: merchant_id) }

  class << self
    def update_expired_status(mac)
      AuthToken.where(mac: mac, status: 1).where(["expired_timestamp < :expired_timestamp", { expired_timestamp: Time.now.to_i }]).update_all(status: 2)
    end
  end

  def left_duration
    if expired_timestamp
      (self.expired_timestamp - Time.now.to_i) > 0 ? (self.expired_timestamp - Time.now.to_i) : 0
    else
      0
    end
  end

  def update_and_send_to_terminal(expired_timestamp: expired_timestamp,duration: duration, status: status, account_id: account_id)
    transaction do
      account_id = account_id || self.account_id
      if self.update(expired_timestamp: expired_timestamp, duration: duration, status: status, account_id: account_id)
        if address = NatAddress.address(self.mac.downcase)
          remote_ip, port, time = address.split("#")
          recv_data = send_to_terminal remote_ip, port, self, 1
          
          if recv_data.present?
            self.update(status: status)
          else
            message = "can not recv data..."
            Communicate.logger.add Logger::FATAL, message
            false
          end
        else
          message = "no nat address..."
          Communicate.logger.add Logger::FATAL, message
          false
        end
      end
    end

  end

  def update_status
    if self.expired_timestamp.present? && self.active? && self.expired_timestamp.to_i < Time.now.to_i
      self.update_columns(status: AuthToken.statuses[:expired])
    end
  end

end
