module Vtoken

  def generate_vtoken mac, client_identifier, timestamp
    # strip `:` in mac address and then reverse it
    reverse_mac = mac.delete(':').reverse
    reverse_client_identifier = client_identifier.delete(':').reverse
    # transfer the first and last half of it
    exchange_mac = [reverse_mac[6..11], reverse_mac[0..5], reverse_client_identifier[6..11], reverse_client_identifier[0..5]].sample(2).inject(:+)
    # generate a number array based on timestamp to perform sort
    sort_weight = Digest::MD5.hexdigest(timestamp.to_s)[0..23].chars.each_slice(2).map { |s| s.join.to_i 16 }
    # then sort it
    index = -1
    sort_mac = exchange_mac.chars.to_a.sort_by! { |k| sort_weight[index += 1] + index.to_f/100 }.join
    # hmac-sha1
    result = Base64.urlsafe_encode64(HMAC::SHA1.digest(private_key, sort_mac)).strip
    result
  end
    
end