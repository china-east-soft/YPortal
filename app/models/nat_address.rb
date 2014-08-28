class NatAddress

  class << self

    def ping(mac, ip, port)
      store(mac, ip, port)
    end

    def address(mac)
      address = $redis.get(self.redis_key(mac))

      remote_ip, port, time.to_i = address.split("#")
      if Time.now.to_i - time > 180
        logger.fatal "nataddress #{remote_ip}:#{port} form redis is outtime(#{time}), please check the hiredis-example program or the terminal is not connect to this server."
      end

      address
    end

    # helper method to generate redis keys
    def redis_key(str)
      "nat_address##{str}"
    end
  end

end
