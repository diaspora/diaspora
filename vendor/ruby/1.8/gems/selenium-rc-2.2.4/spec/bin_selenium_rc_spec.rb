require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

describe "bin/selenium-rc" do
  attr_reader :root_dir
  before do
    dir = File.dirname(__FILE__)
    @root_dir = File.expand_path("#{dir}/..")
    unless File.exists?("#{root_dir}/vendor/selenium-server.jar")
      raise "vendor/selenium-server.jar does not exist. Try running `rake download_jar_file` to install the jar file."
    end
  end

  it "starts the SeleniumRC server from the downloaded jar file and terminates it when finished" do
    thread = nil
    Dir.chdir(root_dir) do
      thread = Thread.start do
        system("bin/selenium-rc") || raise("bin/selenium-server failed")
      end
    end

    server = SeleniumRC::Server.new("0.0.0.0")

    timeout {server.service_is_running?}
    thread.kill
    Lsof.kill(4444)
    timeout {!server.service_is_running?}
  end

  def timeout
    start_time = Time.now
    timeout_length = 15
    until yield
      if Time.now > (start_time + timeout_length)
        raise SocketError.new("Socket did not open/close within #{timeout_length} seconds")
      end
    end
  end
end
