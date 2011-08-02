require 'capistrano/errors'

module Capistrano
  module Deploy
    class RemoteDependency
      attr_reader :configuration
      attr_reader :hosts

      def initialize(configuration)
        @configuration = configuration
        @success = true
        @hosts = nil
      end

      def directory(path, options={})
        @message ||= "`#{path}' is not a directory"
        try("test -d #{path}", options)
        self
      end

      def file(path, options={})
        @message ||= "`#{path}' is not a file"
        try("test -f #{path}", options)
        self
      end

      def writable(path, options={})
        @message ||= "`#{path}' is not writable"
        try("test -w #{path}", options)
        self
      end

      def command(command, options={})
        @message ||= "`#{command}' could not be found in the path"
        try("which #{command}", options)
        self
      end

      def gem(name, version, options={})
        @message ||= "gem `#{name}' #{version} could not be found"
        gem_cmd = configuration.fetch(:gem_command, "gem")
        try("#{gem_cmd} specification --version '#{version}' #{name} 2>&1 | awk 'BEGIN { s = 0 } /^name:/ { s = 1; exit }; END { if(s == 0) exit 1 }'", options)
        self
      end

      def match(command, expect, options={})
        expect = Regexp.new(Regexp.escape(expect.to_s)) unless expect.is_a?(Regexp)

        output_per_server = {} 
        try("#{command} ", options) do |ch, stream, out| 
          output_per_server[ch[:server]] ||= '' 
          output_per_server[ch[:server]] += out 
        end 

        # It is possible for some of these commands to return a status != 0
        # (for example, rake --version exits with a 1). For this check we
        # just care if the output matches, so we reset the success flag.
        @success = true

        errored_hosts = [] 
        output_per_server.each_pair do |server, output| 
          next if output =~ expect
          errored_hosts << server 
        end 

        if errored_hosts.any?
          @hosts = errored_hosts.join(', ')
          output = output_per_server[errored_hosts.first]
          @message = "the output #{output.inspect} from #{command.inspect} did not match #{expect.inspect}"
          @success = false
        end 

        self 
      end

      def or(message)
        @message = message
        self
      end

      def pass?
        @success
      end

      def message
        s = @message.dup
        s << " (#{@hosts})" if @hosts
        s
      end

    private

      def try(command, options)
        return unless @success # short-circuit evaluation
        configuration.invoke_command(command, options) do |ch,stream,out|
          warn "#{ch[:server]}: #{out}" if stream == :err
          yield ch, stream, out if block_given?
        end
      rescue Capistrano::CommandError => e
        @success = false
        @hosts = e.hosts.join(', ')
      end
    end
  end
end
