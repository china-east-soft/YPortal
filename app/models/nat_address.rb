class NatAddress

  class << self

    def ping(mac, ip, port)
      store(mac, ip, port)
    end

    def address(mac)
      address = $redis.get(self.redis_key(mac))

      if address
        time = address.split("#").last

        if Time.now.to_i - time.to_i > 60
          Rails.logger.fatal "nataddress #{remote_ip}:#{port} from redis is outtime(#{time}), please check if the hiredis program is not runing or the terminal is not connect to this server."
        end
      else
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
