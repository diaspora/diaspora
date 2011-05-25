#This class is for running servers in the background during integration testing.  This will not run on Windows.
class Server
  def self.all
    @servers ||= ActiveRecord::Base.configurations.keys.select{
      |k| k.include?("integration")
    }.map{ |k| self.new(k) }
  end

  attr_reader :port, :env
  def initialize(env)
    @config = ActiveRecord::Base.configurations[env]
    @port = @config["app_server_port"]
    @env = env
  end

  def running?
    begin
      RestClient.get("localhost:#{@port}/users/sign_in")
      true
    rescue Errno::ECONNREFUSED
      false
    end
  end

  def db
    former_env = Rails.env
    ActiveRecord::Base.establish_connection(env)
    yield
    ActiveRecord::Base.establish_connection(former_env)
  end

  def truncate_database
    db do
      DatabaseCleaner.clean_with(:truncation)
    end
  end
end
