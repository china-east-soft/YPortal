require 'csv'

class Terminal < ActiveRecord::Base

  enum status: [:init, :active, :expired, :cancelling, :cancelled, :repair, :trash]

  include PrivateKey
  include Communicate
  extend OpenSpreadsheet

  belongs_to :merchant
  belongs_to :agent
  belongs_to :terminal_version
  has_many :auth_tokens, dependent: :destroy

  before_create :set_mid, :set_duration, :set_terminal_version

  after_create do
    update_attribute :operate_log, "设备初始化;"
  end

  validates :mac, format: { with: /\A([a-f0-9]{2}:){5}[a-f0-9]{2}\z/ }, uniqueness: true

  validates_presence_of :mac, :agent, on: :create

  def set_mid
    self.mid = generate_mid mac, Time.now
    while Terminal.exists?(mid: self.mid)
      self.mid = generate_mid mac, Time.now
    end
  end

  def set_duration
    self.duration = 60 * 60 * 4
    self.status = Terminal.statuses[:init]
  end

  around_update :notify_terminal_if_duration_is_changed

  attr_accessor :beaut_duration

  def beaut_duration
    self.duration/(60)
  end

  def beaut_duration=(bdu)
    self.duration = bdu.to_i*(60)
  end

  before_validation do
    mac.downcase!
    add_mac_colon!
  end

  # add colon seperator to mac address
  def add_mac_colon!
    unless mac.include? ':'
      self.mac = mac.to_s.chars.each_slice(2).map(&:join).join(':')
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["\xEF\xBB\xBFmac", "imei"]
    end
  end

  def self.import(file, agent_id)
    begin
      Terminal.transaction do
        file = open_spreadsheet(file)
        CSV.foreach(file.path, headers: true) do |row|
          row.to_hash.each do |key,value|
            terminal = Terminal.new
            value.split("\t").each_with_index do |attr_value,index|
              case index
              when 0
                terminal.mac = attr_value
              when 1
                terminal.imei = attr_value
              end
            end
            terminal.agent_id = agent_id

            terminal.save!
          end
        end
      end
      true
    rescue => e
      raise e
    end
  end


 #####增加库存功能################
  scope :active, -> { where status: Terminal.statuses[:active] }
  scope :normal, -> { where status: [Terminal.statuses[:init], Terminal.statuses[:active]] }
  scope :unnormal, -> { where status: [Terminal.statuses[:repair], Terminal.statuses[:cancel], Terminal.statuses[:trash]] }

  def active(merchant_id)
    operate_record = "#{operate_log}#{I18n.l Time.now }由商家(id:#{merchant_id})激活;"
    merchant = Merchant.find merchant_id
    update_attributes(merchant_id: merchant_id, agent_id: merchant.agent_id, status: AuthToken.statuses[:active], added_by_merchant_at: Time.now, operate_log: operate_record)
  end

  def init(admin_email)
    #只能从退货或者维修状态转化为初始状态
    unless repair? || cancelled?
      logger.debug "无法从其它状态改为初始状态"
      return false
    end

    operate_record = "#{operate_log}#{I18n.l Time.now }由管理员(#{admin_email})改为初始状态;"
    update_attributes status: Terminal.statuses[:init], operate_log: operate_record, merchant_id: nil, agent_id: nil
  end

  def cancelling
    operate_record = "#{operate_log}#{I18n.l Time.now }由商户(id:#{merchant_id})发起退货请求;"
    update_attributes status: Terminal.statuses[:cancelling], operate_log: operate_record
  end

  def uncancelling(admin_email)
    operate_record = "#{operate_log}#{I18n.l Time.now }管理员(#{admin_email})不同意退货;"
    update_attributes status: Terminal.statuses[:active], operate_log: operate_record
  end

  def cancelled(admin_email)
    operate_record = "#{operate_log}#{I18n.l Time.now }由管理员(#{admin_email})同意发退货请求;"
    update_attributes status: Terminal.statuses[:cancelled], operate_log: operate_record, merchant_id: nil, agent_id: nil
  end

  def repair(admin_email)
    operate_record = "#{operate_log}#{I18n.l Time.now }由管理员(#{admin_email})改为维修状态;"
    update_attributes status: Terminal.statuses[:repair], operate_log: operate_record
  end

  def trash(admin_email)
    operate_record = "#{operate_log}#{I18n.l Time.now }由管理员(#{admin_email})改为报废状态;"
    update_attributes status: Terminal.statuses[:trash], operate_log: operate_record, merchant_id: nil, agent_id: nil
  end

  def normal?
    init? || active?
  end

  def unnormal?
    !normal?
  end

  def disable_cancelled?
    trash? || cancelled? || init?
  end

  def disabel_repair?
    trash? || repair?
  end
  ################# end #############

  private

    def notify_terminal_if_duration_is_changed
      duration_changed = self.duration_changed?

      yield

      if duration_changed && self.active? && self.merchant_id.present?

        actived_auth_tokens = self.auth_tokens.actived(self.merchant_id).where(mac: self.mac)

        auth_token_sample = self.auth_tokens.last

        actived_auth_tokens.each do |auth_token|
          auth_token.update_terminal_duration(self.duration)
        end

        if auth_token_sample
          logger.debug "duration changed, and notify terminal:#{self.mac}"

          address = NatAddress.address(self.mac.downcase)
          if address
            remote_ip, port, time = address.split("#")

            recv_data = send_to_terminal remote_ip, port, auth_token_sample, 7, duration: self.duration
            if recv_data.nil?
              logger.debug "can't notify terminal for duration change"
            else
              logger.debug "notify termianl for duration change success"
            end
          else
            logger.debug "can not find nat address for terminal #{self.mac}"
          end
        end
      end

    end

    def generate_mid mac, timestamp
      reverse_mac = mac.delete(':').reverse
      exchange_mac = [reverse_mac[8..11], reverse_mac[0..3], reverse_mac[4..7]].inject(:+)
      sort_weight = Digest::MD5.hexdigest(timestamp.to_s)[0..23].chars.each_slice(2).map { |s| s.join.to_i 16 }
      index = -1
      sort_mac = exchange_mac.chars.to_a.sort_by! { |k| sort_weight[index += 1] + index.to_f/100 }.join
      result = Base64.urlsafe_encode64(HMAC::SHA1.digest(private_key, sort_mac)).strip
      sample_arr = ('a'..'z').to_a + ('A'..'Z').to_a - %w{ 0 1 l I o O}
      result = result.first(8)
      %w{ 0 1 l I o O }.each do |k|
        result.gsub!(k,sample_arr.sample)
      end
      #result.first(8).gsub(/[01IoO]/,sample_arr.sample)
      result
    end

    def set_terminal_version
      lastest_version = TerminalVersion.where(release: true).order('created_at desc').first
      if lastest_version
        self.terminal_version_id = lastest_version.id
      end
    end


end
