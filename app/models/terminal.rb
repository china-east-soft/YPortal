class Terminal < ActiveRecord::Base

  include PrivateKey

  belongs_to :merchant
  belongs_to :agent

  after_create :set_mid

  def set_mid
    self.mid = generate_mid mac, Time.now, self.id
    self.update_column :mid, self.mid
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
