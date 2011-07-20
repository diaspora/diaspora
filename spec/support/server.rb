#This class is for running servers in the background during integration testing.  This will not run on Windows.
class Server
  def self.all
    @servers ||= ActiveRecord::Base.configurations.keys.select{
      |k| k.include?("integration")
    }.map{ |k| self.new(k) }
  end

  attr_reader :port, :env
  def initialize(env)
    @db_config = ActiveRecord::Base.configurations[env]
    @app_config = (YAML.load_file AppConfig.source)[env]
    @port = URI::parse(@app_config["pod_url"]).port
    @env = env
    ensure_database_setup
  end

  def ensure_database_setup
    `cd #{Rails.root} && RAILS_ENV=#{@env} bundle exec rake db:create`
    tables_exist = self.db do
      ActiveRecord::Base.connection.tables.include?("users")
    end
    if tables_exist
      truncate_database
    else
      `cd #{Rails.root} && RAILS_ENV=#{@env} bundle exec rake db:schema:load`
    end
  end

  def run
    @pid = fork do
      Process.exec "cd #{Rails.root} && RAILS_ENV=#{@env} bundle exec #{run_command}"
    end
  end

  def kill
    puts "I am trying to kill the server"
    `kill -9 #{get_pid}`
  end

  def run_command
    "rails s thin -p #{@port}"
  end

  def get_pid
    @pid = lambda {
      processes = `ps ax -o pid,command | grep "#{run_command}"`.split("\n")
      processes = processes.select{|p| !p.include?("grep") }
      processes.first.split(" ").first
    }.call
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
    begin
      result = yield
    ensure
      ActiveRecord::Base.establish_connection(former_env)
    end
    result
  end

  def truncate_database
    db do
      DatabaseCleaner.clean_with(:truncation)
    end
  end

  def in_scope
    pod_url = "http://localhost:#{@port}/"
    AppConfig.stub!(:pod_url).and_return(pod_url)
    AppConfig.stub!(:pod_uri).and_return(Addressable::URI.parse(pod_url))
    begin
      result = db do
         yield
      end
    ensure
      AppConfig.unstub!(:pod_url)
      AppConfig.unstub!(:pod_uri)
    end
    result
  end
end
