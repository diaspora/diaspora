lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))

if File.exist?(File.join(lib_dir, 'daemons.rb'))
  $LOAD_PATH.unshift lib_dir
else
  begin; require 'rubygems'; rescue ::Exception; end
end



require 'daemons'


testfile = File.expand_path(__FILE__) + '.log'

Daemons.daemonize

File.open(testfile, 'w') {|f|
  f.write("test")
}