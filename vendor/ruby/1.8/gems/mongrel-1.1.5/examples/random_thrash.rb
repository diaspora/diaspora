require 'socket'
devrand = open("/dev/random","r")

loop do
  s = TCPSocket.new(ARGV[0],ARGV[1])
  s.write("GET / HTTP/1.1\r\n")
  total = 0
  begin
    loop do
       r = devrand.read(10)
       n = s.write(r)
       total += n
    end  
  rescue Object
	STDERR.puts "#$!: #{total}"
  end
   s.close
   sleep 1
end
