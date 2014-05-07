class NatAddress

  class << self

    def ping(mac, ip, port)
      store(mac, ip, port)
    end

    def address(mac)
      $redis.get(self.redis_key(mac))
    end  

    # helper method to generate redis keys
    def redis_key(str)
      "nat_address##{str}"
    end
  end

end