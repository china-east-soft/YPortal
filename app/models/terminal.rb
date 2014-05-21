require 'csv'

class Terminal < ActiveRecord::Base

  include PrivateKey
  extend OpenSpreadsheet

  belongs_to :merchant
  belongs_to :agent

  after_create :set_mid

  validates :mac, format: { with: /\A([a-f0-9]{2}:){5}[a-f0-9]{2}\z/ }, uniqueness: true

  validates_presence_of :mac

  def set_mid
    self.mid = generate_mid mac, Time.now, self.id
    self.update_column :mid, self.mid
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

  def self.import(file)
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

            terminal.save!
          end
        end
      end
      true
    rescue => e 
      raise e
    end
  end

  private

    def generate_mid mac, timestamp, tid
      reverse_mac = mac.delete(':').reverse
      exchange_mac = [reverse_mac[8..11], reverse_mac[0..3], reverse_mac[4..7]].inject(:+)
      sort_weight = Digest::MD5.hexdigest(timestamp.to_s)[0..23].chars.each_slice(2).map { |s| s.join.to_i 16 }
      index = -1
      sort_mac = exchange_mac.chars.to_a.sort_by! { |k| sort_weight[index += 1] + index.to_f/100 }.join
      result = Base64.urlsafe_encode64(HMAC::SHA1.digest(private_key, sort_mac)).strip
      tid.to_s + '-' + result.first(8)
    end

end
