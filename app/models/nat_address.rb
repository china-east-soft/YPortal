class NatAddress

  class << self

    def ping(mac, ip, port)
      store(mac, ip, port)
    end

    def address(mac)
      address = $redis.get(self.redis_key(mac))

      begin
        remote_ip, port, time = address.split("#")
        if Time.now.to_i - time.to_i > 180
          Rails.logger.fatal "nataddress #{remote_ip}:#{port} form redis is outtime(#{time}), please check the hiredis-example program or the terminal is not connect to this server."
        end
      rescue
        Rails.logger.fatal "can not find address for #{mac}"
      end

      address
    end

    # helper method to generate redis keys
    def redis_key(str)
      "nat_address##{str}"
    end
  end

end
