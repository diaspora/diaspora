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
    
    alias_method :prevent_fetching_community_spotlight?, :heroku?
    
    def release?
      heroku? || git_available?  #TODO: improve
    end
    alias_method :expose_git_info?, :release?
    
    def git_revision
      get_git_info if expose_git_info?
      @git_revision
    end
    
    def git_update
      get_git_info if expose_git_info?
      @git_update
    end
    
    def rails_asset_id
      (git_revision || version)[0..8]
    end
    
    def get_redis_instance
      if redistogo_url.present?
        puts "WARNING: using the REDISTOGO_URL environment variable is deprecated, please use REDIS_URL now."
        ENV['REDIS_URL'] = redistogo_url
      end
      
      redis_options = {}
    
      redis_url = ENV['REDIS_URL'] || environment.redis
      
      if ENV['RAILS_ENV']== 'integration2'
        redis_options = { :host => 'localhost', :port => 6380 }
      elsif redis_url.present?
        puts "WARNING: You're redis url doesn't start with redis://" unless redis_url.start_with?("redis://")
        redis_options = { :url => redis_url }
      end
      
      Redis.new(redis_options.merge(:thread_safe => true))
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
    
    def git_available?
      return @git_available if @git_available
      `which git`
      @git_available = $?.success?
    end
  end
end
