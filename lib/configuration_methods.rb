module Configuration
  module Methods
    def pod_uri
      return @pod_uri unless @pod_uri.nil?
      
      url = environment.url.get
      url = "http://#{url}" unless url =~ /^(https?:\/\/)/
      url << "/" unless url.end_with?("/")
      
      begin
        @pod_url = Addressable::URI.parse(url)
      rescue
        puts "WARNING: pod url #{url} is not a legal URI"
      end
      
      @pod_url
    end
    
    def bare_pod_uri
      pod_uri.authority.gsub('www.', '')
    end
    
    def configured_services
      return @configured_services unless @configured_services.nil?
      
      @configured_services = []
      [:twitter, :tumblr, :facebook].each do |service|
        @configured_services << service if services.send(service).enable?
      end
      
      @configured_services
    end
    attr_writer :configured_services
    
    def secret_token
      return ENV['SECRET_TOKEN'] if ENV['SECRET_TOKEN']
      $stderr.puts "FATAL: Running on Heroku with SECRET_TOKEN unset"
      $stderr.puts "       Run heroku config:add SECRET_TOKEN=#{SecureRandom.hex(40)}"
      Process.exit(1)
    end
    
    def version_string
      return @version_string unless @version_string.nil?
      @version_string = version.number.to_s
      @version_string << "-p#{git_revision[0..7]}" if git_available?
      @version_string
    end
    
    def git_available?
      return @git_available unless @git_available.nil?
      
      if heroku?
        @git_available = false
      else
        `which git`
        `git status 2> /dev/null` if $?.success?
        @git_available = $?.success?
      end
    end
    
    def git_revision
      get_git_info if git_available?
      @git_revision
    end
    attr_writer :git_revision
    
    def git_update
      get_git_info if git_available?
      @git_update
    end
    attr_writer :git_update
    
    def rails_asset_id
      (git_revision || version)[0..8]
    end
    
    def get_redis_options
      if redistogo_url.present?
        $stderr.puts "WARNING: using the REDISTOGO_URL environment variable is deprecated, please use REDIS_URL now."
        ENV['REDIS_URL'] = redistogo_url
      end
      
      redis_options = {}
    
      redis_url = ENV['REDIS_URL'] || environment.redis.get
      
      if ENV['RAILS_ENV']== 'integration2'
        redis_options[:url] = "redis://localhost:6380"
      elsif redis_url.present?
        unless redis_url.start_with?("redis://") || redis_url.start_with?("unix:///")
          $stderr.puts "WARNING: Your redis url (#{redis_url}) doesn't start with redis:// or unix:///"
        end
        redis_options[:url] = redis_url
      end
      
      redis_options[:namespace] = AppConfig.environment.sidekiq.namespace.get
      
      redis_options
    end
    
    def sidekiq_log
      path = Pathname.new environment.sidekiq.log.get
      path = Rails.root.join(path) unless pathname.absolute?
      path.to_s
    end

    private

    def get_git_info
      return if git_info_present? || !git_available?
      
      git_cmd = `git log -1 --pretty="format:%H %ci"`
      if git_cmd =~ /^([\d\w]+?)\s(.+)$/
        @git_revision = $1
        @git_update = $2.strip
      end
    end
    
    def git_info_present?
      @git_revision || @git_update
    end
  end
end
