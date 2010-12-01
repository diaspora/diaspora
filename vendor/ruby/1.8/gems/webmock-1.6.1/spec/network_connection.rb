module NetworkConnection
  def self.connect_to(host, port, timeout=nil)
    addr = Socket.getaddrinfo(host, nil)
    sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

    if timeout
      secs = Integer(timeout)
      usecs = Integer((timeout - secs) * 1_000_000)
      optval = [secs, usecs].pack("l_2")
      sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
      sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
    end
    sock.connect(Socket.pack_sockaddr_in(port, addr[0][3]))
    sock
  end

  def self.is_network_available?
    begin
      self.connect_to("192.0.32.10", 80, 5)
      true
    rescue
      false
    end
  end
end