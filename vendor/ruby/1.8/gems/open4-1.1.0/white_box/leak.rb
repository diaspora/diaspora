require 'open4'

pid = Process.pid
fds = lambda{|pid| Dir["/proc/#{ pid }/fd/*"]}

loop do
  before = fds[pid] 
  Open4.popen4 'ruby -e"buf = STDIN.read; STDOUT.puts buf; STDERR.puts buf "' do |p,i,o,e|
    i.puts 42
    i.close_write
    o.read
    e.read
  end
  after = fds[pid] 
  p(after - before)
  puts
end
