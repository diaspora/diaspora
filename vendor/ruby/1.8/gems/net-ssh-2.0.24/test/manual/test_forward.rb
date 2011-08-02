#     $ ruby -Ilib -Itest -rrubygems test/test_forward.rb

# Tests for the following patch:
#
#   http://github.com/net-ssh/net-ssh/tree/portfwfix
# 
# It fixes 3 issues, regarding closing forwarded ports:
# 
# 1.) if client closes a forwarded connection, but the server is reading, net-ssh terminates with IOError socket closed.
# 2.) if client force closes (RST) a forwarded connection, but server is reading, net-ssh terminates with
# 3.) if server closes the sending side, the on_eof is not handled.
# 
# More info:
# 
# http://net-ssh.lighthouseapp.com/projects/36253/tickets/7

require 'common'
require 'net/ssh/buffer'
require 'net/ssh'
require 'timeout'

class TestForward < Test::Unit::TestCase
  
  def localhost
    'localhost'
  end
  
  def ssh_start_params
    [localhost ,ENV['USER']] #:verbose => :debug
  end
  
  def find_free_port 
    server = TCPServer.open(0)
    server.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR,true)
    port = server.addr[1]
    server.close
    port
  end
  
  def start_server_sending_lot_of_data(exceptions)
    server = TCPServer.open(0)
    Thread.start do
      loop do
        Thread.start(server.accept) do |client|
          begin
            10000.times do |i| 
              client.puts "item#{i}"
            end
            client.close
          rescue 
            exceptions << $!
            raise
          end
        end
      end
    end
    return server
  end
  
  def start_server_closing_soon(exceptions=nil)
    server = TCPServer.open(0)
    Thread.start do
      loop do
        Thread.start(server.accept) do |client|
          begin
            client.recv(1024) 
            client.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, [1, 0].pack("ii"))
            client.close
          rescue
            exceptions <<  $!
            raise
          end
        end
      end
    end
    return server
  end
  
  def test_loop_should_not_abort_when_local_side_of_forward_is_closed
    session = Net::SSH.start(*ssh_start_params) 
    server_exc = Queue.new
    server = start_server_sending_lot_of_data(server_exc)
    remote_port = server.addr[1]
    local_port = find_free_port
    session.forward.local(local_port, localhost, remote_port)
    client_done = Queue.new
    Thread.start do
      begin
        client = TCPSocket.new(localhost, local_port)
        client.recv(1024)
        client.close
        sleep(0.2)
      ensure
        client_done << true
      end
    end
    session.loop(0.1) { client_done.empty? }
    assert_equal "Broken pipe", "#{server_exc.pop}" unless server_exc.empty?
  end
  
  def test_loop_should_not_abort_when_local_side_of_forward_is_reset
    session = Net::SSH.start(*ssh_start_params)
    server_exc = Queue.new    
    server = start_server_sending_lot_of_data(server_exc)
    remote_port = server.addr[1]
    local_port = find_free_port
    session.forward.local(local_port, localhost, remote_port)
    client_done = Queue.new
    Thread.start do
      begin
        client = TCPSocket.new(localhost, local_port)
        client.recv(1024)
        client.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, [1, 0].pack("ii"))
        client.close
        sleep(0.1)
      ensure
        client_done << true
      end
    end
    session.loop(0.1) { client_done.empty? }
    assert_equal "Broken pipe", "#{server_exc.pop}" unless server_exc.empty?
  end
  
  def test_loop_should_not_abort_when_server_side_of_forward_is_closed
    session = Net::SSH.start(*ssh_start_params)    
    server = start_server_closing_soon
    remote_port = server.addr[1]
    local_port = find_free_port
    session.forward.local(local_port, localhost, remote_port)
    client_done = Queue.new
    Thread.start do
      begin
        client = TCPSocket.new(localhost, local_port)
        1.times do |i| 
          client.puts "item#{i}"
        end
        client.close
        sleep(0.1)
      ensure                 
        client_done << true
      end
    end
    session.loop(0.1) { client_done.empty? }
  end
  
  def start_server
    server = TCPServer.open(0)
    Thread.start do
      loop do
        Thread.start(server.accept) do |client|
          yield(client)
        end
      end
    end
    return server
  end
  
  def test_server_eof_should_be_handled
    session = Net::SSH.start(*ssh_start_params)    
    server = start_server do |client|
      client.write "This is a small message!"
      client.close
    end
    client_done = Queue.new
    client_exception = Queue.new
    client_data = Queue.new
    remote_port = server.addr[1]
    local_port = find_free_port
    session.forward.local(local_port, localhost, remote_port)
    Thread.start do
      begin
        client = TCPSocket.new(localhost, local_port)
        data = client.read(4096)
        client.close
        client_done << data
      rescue
        client_done << $!
      end
    end
    timeout(5) do
      session.loop(0.1) { client_done.empty? }
      assert_equal "This is a small message!", client_done.pop
    end
  end
end