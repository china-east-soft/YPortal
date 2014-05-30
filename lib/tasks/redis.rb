namespace :redis do
  
  desc 'clear invalid keys'
  task :clear_invalid_keys => :environment do
    nat_keys = $redis.keys('nat_address#*')
    nat_values = $redis.mget(nat_keys)
    key_values = nat_keys.zip nat_values
    invalid_key_values = key_values.select do |kv|
      k, v = kv
      time = v.split("#")[2]
      if time
        time.to_i < Time.now.to_i - 5.days.to_i
      else
        true
      end
    end
    invalid_keys = invalid_key_values.map{|i| i[0] }
    $redis.del invalid_keys
  end

end