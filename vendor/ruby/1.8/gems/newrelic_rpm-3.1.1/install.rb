if __FILE__ == $0 || $0 =~ /script\/plugin/
  $LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  require 'new_relic/command'
  begin
    NewRelic::Command::Install.new(:quiet => true, :app_name => 'My Application').run
  rescue NewRelic::Command::CommandFailure => e
    $stderr.puts e.message
  end
end
