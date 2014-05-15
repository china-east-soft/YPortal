require 'socket'

module NoBlockUDP

  def no_block_recvfrom send_data, remote_ip, port, max_delay, step

    i = 0; 
    begin
      t = UDPSocket.new
      t.send(send_data, 0, remote_ip, port)
      begin
        recv_data = t.recv_nonblock(100); #也可用read_nonblock代替
        recv_data.strip!;
      rescue IO::WaitReadable
       i = i + step;
       if i<max_delay #最大等待时间
          sleep(i/1000); # 等待1秒
          puts i
          #IO.select([t]); # 此行会导致recv_nonblock阻塞
          retry;
       end
      end
      
      t.close;
      if recv_data.present?
        puts recv_data;
      else
        puts "Server is not ok!";
      end

    rescue Errno::ECONNREFUSED
      ph_ok = false;
      puts "server not in listening!";
    rescue Exception=>ex
      puts ex.to_s;
    end

    recv_data

  end

end