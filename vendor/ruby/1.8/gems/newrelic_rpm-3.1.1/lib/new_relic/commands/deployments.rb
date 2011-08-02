# This is a class for executing commands related to deployment
# events.  It runs without loading the rails environment

require 'yaml'
require 'net/http'
require 'rexml/document'

# We need to use the Control object but we don't want to load
# the rails/merb environment.  The defined? clause is so that
# it won't load it twice, something it does when run inside a test
require 'new_relic/control' unless defined? NewRelic::Control

class NewRelic::Command::Deployments < NewRelic::Command
  attr_reader :config
  def self.command; "deployments"; end

  # Initialize the deployment uploader with command line args.
  # Use -h to see options.
  # When command_line_args is a hash, we are invoking directly and
  # it's treated as an options with optional sttring values for
  # :user, :description, :appname, :revision, :environment,
  # and :changes.
  #
  # Will throw CommandFailed exception if there's any error.
  #
  def initialize command_line_args
    @config = NewRelic::Control.instance
    super(command_line_args)
    @description ||= @leftover && @leftover.join(" ")
    @user ||= ENV['USER']
    config.env = @environment if @environment
    @appname ||= config.app_names[0] || config.env || 'development'
  end

  # Run the Deployment upload in New Relic via Active Resource.
  # Will possibly print errors and exit the VM
  def run
    begin
      @description = nil if @description && @description.strip.empty?
      create_params = {}
      {
            :application_id => @appname,
            :host => Socket.gethostname,
            :description => @description,
            :user => @user,
            :revision => @revision,
            :changelog => @changelog
      }.each do |k, v|
        create_params["deployment[#{k}]"] = v unless v.nil? || v == ''
      end
      http = config.http_connection(config.api_server)

      uri = "/deployments.xml"

      raise "license_key was not set in newrelic.yml for #{config.env}" if config['license_key'].nil?
      request = Net::HTTP::Post.new(uri, {'x-license-key' => config['license_key']})
      request.content_type = "application/octet-stream"

      request.set_form_data(create_params)

      response = http.request(request)

      if response.is_a? Net::HTTPSuccess
        info "Recorded deployment to '#{@appname}' (#{@description || Time.now })"
      else
        err_string = REXML::Document.new(response.body).elements['errors/error'].map(&:to_s).join("; ") rescue  response.message
        raise NewRelic::Command::CommandFailure, "Deployment not recorded: #{err_string}"
      end
    rescue SystemCallError, SocketError => e
      # These include Errno connection errors
      err_string = "Transient error attempting to connect to #{config.api_server} (#{e})"
      raise NewRelic::Command::CommandFailure.new(err_string)
    rescue NewRelic::Command::CommandFailure
      raise
    rescue Exception => e
      err "Unexpected error attempting to connect to #{config.api_server}"
      info "#{e}: #{e.backtrace.join("\n   ")}"
      raise NewRelic::Command::CommandFailure.new(e.to_s)
    end
  end

  private

  def options
    OptionParser.new %Q{Usage: #{$0} #{self.class.command} [OPTIONS] ["description"] }, 40 do |o|
      o.separator "OPTIONS:"
      o.on("-a", "--appname=NAME", String,
             "Set the application name.",
             "Default is app_name setting in newrelic.yml") { | e | @appname = e }
      o.on("-e", "--environment=name", String,
               "Override the (RAILS|MERB|RUBY|RACK)_ENV setting",
               "currently: #{config.env}") { | e | @environment = e }
      o.on("-u", "--user=USER", String,
             "Specify the user deploying, for information only",
             "Default: #{@user || '<none>'}") { | u | @user = u }
      o.on("-r", "--revision=REV", String,
             "Specify the revision being deployed") { | r | @revision = r }
      o.on("-c", "--changes",
             "Read in a change log from the standard input") { @changelog = STDIN.read }
      yield o if block_given?
    end
  end


end
