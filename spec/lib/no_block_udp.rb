require 'spec_helper'
require 'socket'

describe "no block udp" do

  let(:s1) {
    s1 = UDPSocket.new
    s1.bind("127.0.0.1", 0)
    s1
  }

  let(:s2) {
    s2 = UDPSocket.new
    s2.bind("127.0.0.1", 0)
    s2
  }

  before do
    s2.connect(*s1.addr.values_at(3,1))
    s1.connect(*s2.addr.values_at(3,1))
  end

  it "should be no block" do

    s1.send "aaa", 0

    max_delay= 1000
    i = 0; 

      begin
        recv_data = s2.recv_nonblock(100); #也可用read_nonblock代替
        recv_data.strip!;
      rescue IO::WaitReadable
       i = i + 300;
       if i<max_delay #最大等待时间
          sleep(i/1000); # 等待1秒
          puts i
          #IO.select([t]); # 此行会导致recv_nonblock阻塞
          retry;
       end
      end

      #s2.close;
      if recv_data.present?
        puts recv_data;
      else
        puts "Server is not ok!";
      end

    expect(recv_data).to eq('aaa')

  end

it "should be no block" do

    max_delay= 1000
    i = 0; 

      begin
        recv_data = s2.recv_nonblock(100); #也可用read_nonblock代替
        recv_data.strip!;
      rescue IO::WaitReadable
       i = i + 300;
       if i<max_delay #最大等待时间
          sleep(i/1000); # 等待1秒
          puts i
          #IO.select([t]); # 此行会导致recv_nonblock阻塞
          retry;
       end
      end

      #s2.close;
      if recv_data.present?
        puts recv_data;
      else
        puts "Server is not ok!";
      end

    expect(recv_data).to eq(nil)

  end
    
end
