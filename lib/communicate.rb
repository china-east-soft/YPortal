module Communicate

  include NoBlockUDP

  class << self
    def logger
      Logger.new("#{Rails.root}/log/communicate.log")
    end
  end

  #type:
  # 7 : update duration
  # 1 : account sign in
  # 3 : offline
  def send_to_terminal remote_ip, port, auth_token, type, duration: nil
    version = "\x00".force_encoding('UTF-8')
    case type
    when 1
      type = "\x01".force_encoding('UTF-8')
    when 3
      type = "\x03".force_encoding('UTF-8')
    when 4
      type = "\x04".force_encoding('UTF-8')
    when 7
      type = "\x07".force_encoding('UTF-8')
    end

    flag1 = "\xaa".force_encoding('UTF-8')
    flag2 = "\xbb".force_encoding('UTF-8')

    vtoken = auth_token.auth_token.force_encoding('UTF-8')
    mac = [auth_token.mac.gsub(/:/,'')].pack('H*').force_encoding('UTF-8')
    client_identifier = [auth_token.client_identifier.gsub(/:/,'')].pack('H*').force_encoding('UTF-8')

    if duration
      expired_timestamp = [0].pack("S*")+[duration].pack("S*").reverse.force_encoding('UTF-8')
    else
      expired_timestamp = [0].pack("S*")+[auth_token.expired_timestamp - Time.now.to_i].pack("S*").reverse.force_encoding('UTF-8')
    end
    errcode = "\x00".force_encoding('UTF-8')
    attrnum = "\x01".force_encoding('UTF-8')

    send_data = "#{version}#{type}#{flag1}#{flag2}#{expired_timestamp}#{attrnum}#{errcode}#{vtoken}#{mac}#{client_identifier}\x00\x00"

    logger.debug "*******************send data to terminal:************* "
    logger.debug "terminal info-- ip: #{remote_ip}, port: #{port}, data: #{send_data}"

    max_delay, step = 4000, 1000

    max_retry = 2

    recv_data = nil

    max_retry.times do
      recv_data = no_block_recvfrom send_data, remote_ip, port, max_delay, step
      break if recv_data
    end

    if recv_data.nil?
      logger.debug "error: can not recv data from terminal"
    else
      logger.debug "ok: recv data(#{recv_data}) from terminal"
    end

    recv_data

  end

end
