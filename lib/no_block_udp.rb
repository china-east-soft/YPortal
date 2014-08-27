require 'socket'

module NoBlockUDP

  def no_block_recvfrom send_data, remote_ip, port, max_delay, step

    i = 0;
    begin
      t = UDPSocket.new
      t.send(send_data, 0, remote_ip, port)
      logger.debug "data has send to #{remote_ip}:#{port}, and wait for response."
      begin
        recv_data = t.recv_nonblock(100); #也可用read_nonblock代替
        recv_data.strip!;
      rescue IO::WaitReadable
       i = i + step;
       if i < max_delay #最大等待时间
          sleep(i/1000); # sleep more long ...
          puts i
          #IO.select([t]); # 此行会导致recv_nonblock阻塞
          retry;
       end
      end

      t.close;
      if recv_data.present?
        puts recv_data;
        logger.debug "recv from #{remote_ip}:#{port}, [#{recv_data}]. "
      else
        logger.debug "#{remote_ip}:#{port} not response."
        puts "Server is not ok!";
      end

    rescue Errno::ECONNREFUSED
      logger.debug "#{remote_ip}:#{port} not listening."
      puts "server not in listening!";
    rescue Exception=>ex
      puts ex.to_s;
      logger.debug "recv or send raise error: #{ex.to_s}."
    end

    recv_data
  end

end
