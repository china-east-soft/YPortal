class AuthToken < ActiveRecord::Base

  include Communicate
  include Sidekiq::Worker # include sidekiq worker

  enum status: [ :init, :active, :expired, :test ]

  belongs_to :account
  belongs_to :terminal
  belongs_to :merchant

  validates_uniqueness_of :client_identifier, scope: :mac,
    conditions: -> { where(status: [AuthToken.statuses[:init], AuthToken.statuses[:active]]) },
    :if => Proc.new{ |auth_token| auth_token.init? || auth_token.active? }
  scope :actived, lambda { |merchant_id| where(status: AuthToken.statuses[:active], merchant_id: merchant_id) }

  #############签到##################
  #用AuthToken 作为签到依据， 不再另加签到model

  scope :by_terminal, lambda {|terminal_id| where(terminal_id: terminal_id) }
  scope :before_date, lambda {|date| where(["created_at < ?", 1.days.since(Time.zone.parse(date)).strftime("%Y-%m-%d")])}
  scope :after_date, lambda {|date| where(["created_at >= ?", date])}

  def self.total_grouped_by(date_part)
    case date_part
    when 'day'
      check_ins = self.group("EXTRACT(YEAR from auth_tokens.created_at),DATE(auth_tokens.created_at),auth_tokens.terminal_id")
      check_ins = check_ins.order("max(EXTRACT(YEAR from auth_tokens.created_at)) desc,max(DATE(auth_tokens.created_at)) desc,max(auth_tokens.terminal_id)")
      check_ins = check_ins.select("EXTRACT(YEAR from auth_tokens.created_at) as created_year,DATE(auth_tokens.created_at) as created_part, auth_tokens.terminal_id as terminal_id, count(auth_tokens.id) as total")
    when 'week'
      check_ins = self.group("EXTRACT(ISOYEAR from auth_tokens.created_at),EXTRACT(#{date_part} from auth_tokens.created_at),auth_tokens.terminal_id")
      check_ins = check_ins.order("max(EXTRACT(ISOYEAR from auth_tokens.created_at)) desc,max(EXTRACT(#{date_part} from auth_tokens.created_at)) desc,max(auth_tokens.terminal_id)")
      check_ins = check_ins.select("EXTRACT(ISOYEAR from auth_tokens.created_at) as created_year,EXTRACT(#{date_part} from auth_tokens.created_at) as created_part, auth_tokens.terminal_id as terminal_id, count(auth_tokens.id) as total")
    when 'month','year'
      check_ins = self.group("EXTRACT(YEAR from auth_tokens.created_at),EXTRACT(#{date_part} from auth_tokens.created_at),auth_tokens.terminal_id")
      check_ins = check_ins.order("max(EXTRACT(YEAR from auth_tokens.created_at)) desc,max(EXTRACT(#{date_part} from auth_tokens.created_at)) desc,max(auth_tokens.terminal_id)")
      check_ins = check_ins.select("EXTRACT(YEAR from auth_tokens.created_at) as created_year,EXTRACT(#{date_part} from auth_tokens.created_at) as created_part, auth_tokens.terminal_id as terminal_id, count(auth_tokens.id) as total")
    end
  end
  ##############################end################

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

  def update_terminal_duration(terminal_duration)
    start_at = self.expired_timestamp - self.duration
    auth_token_status = (start_at + terminal_duration) > Time.now.to_i ? AuthToken.statuses[:active] : AuthToken.statuses[:init]
    self.update_columns(duration: terminal_duration, expired_timestamp: start_at + terminal_duration, status: auth_token_status)
  end

  def update_and_send_to_terminal(expired_timestamp: expired_timestamp,duration: duration, status: status, account_id: account_id)
    transaction do
      account_id = account_id || self.account_id
      if self.update_columns(expired_timestamp: expired_timestamp, duration: duration, status: status, account_id: account_id)
        if address = NatAddress.address(self.mac.downcase)
          remote_ip, port, time = address.split("#")
          recv_data = send_to_terminal remote_ip, port, self, 1

          if recv_data.present?
            self.update_columns(status: status)
          else
            message = "can not recv data..."
            Communicate.logger.add Logger::FATAL, message

            DeveloperMailer.delay.system_error_email("[#{I18n.l Time.now}]: error occurs when server send data to terminal", message)
            false
          end
        else
          message = "no nat address..."
          Communicate.logger.add Logger::FATAL, message

          DeveloperMailer.delay.system_error_email("[#{I18n.l Time.now}]: error occurs when server send data to terminal", message)

          false
        end
      end
    end

  end
  # return expired if left duration less than 1 min
  def update_status
    if self.expired_timestamp.present? && self.active? && self.expired_timestamp.to_i < Time.now.to_i + 60
      self.update_columns(status: AuthToken.statuses[:expired])
    end
  end

end
