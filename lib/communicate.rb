module Communicate

  include NoBlockUDP

  def send_to_terminal remote_ip, port, auth_token, type
    version = "\x00".force_encoding('UTF-8')
    case type
    when 1
      type = "\x01".force_encoding('UTF-8')
    end

    flag1 = "\xaa".force_encoding('UTF-8')
    flag2 = "\xbb".force_encoding('UTF-8')

    vtoken = auth_token.auth_token.force_encoding('UTF-8')
    mac = [auth_token.mac.gsub(/:/,'')].pack('H*').force_encoding('UTF-8')
    client_identifier = [auth_token.client_identifier.gsub(/:/,'')].pack('H*').force_encoding('UTF-8')
    
    expired_timestamp = [0].pack("S*")+[auth_token.expired_timestamp - Time.now.to_i].pack("S*").reverse.force_encoding('UTF-8')
    errcode = "\x00".force_encoding('UTF-8')
    attrnum = "\x01".force_encoding('UTF-8')

    send_data = "#{version}#{type}#{flag1}#{flag2}#{expired_timestamp}#{attrnum}#{errcode}#{vtoken}#{mac}#{client_identifier}\x00\x00"

    logger.info send_data

    max_delay, step = 1000, 300

    no_block_recvfrom send_data, remote_ip, port, max_delay, step

  end

end