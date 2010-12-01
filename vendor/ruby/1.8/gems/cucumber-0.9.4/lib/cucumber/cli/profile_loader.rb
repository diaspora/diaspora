require 'yaml'

module Cucumber
  module Cli

    class ProfileLoader

      def initialize
        @cucumber_yml = nil
      end

      def args_from(profile)
        unless cucumber_yml.has_key?(profile)
          raise(ProfileNotFound, <<-END_OF_ERROR)
Could not find profile: '#{profile}'

Defined profiles in cucumber.yml:
  * #{cucumber_yml.keys.join("\n  * ")}
        END_OF_ERROR
        end

        args_from_yml = cucumber_yml[profile] || ''

        case(args_from_yml)
          when String
            raise YmlLoadError, "The '#{profile}' profile in cucumber.yml was blank.  Please define the command line arguments for the '#{profile}' profile in cucumber.yml.\n" if args_from_yml =~ /^\s*$/
            if(Cucumber::WINDOWS)
              #Shellwords treats backslash as an escape character so here's a rudimentary approximation of the same code
              args_from_yml = args_from_yml.split
              args_from_yml = args_from_yml.collect {|x| x.gsub(/^\"(.*)\"/,'\1') }
            else
              require 'shellwords'
              args_from_yml = Shellwords.shellwords(args_from_yml)
            end
          when Array
            raise YmlLoadError, "The '#{profile}' profile in cucumber.yml was empty.  Please define the command line arguments for the '#{profile}' profile in cucumber.yml.\n" if args_from_yml.empty?
          else
            raise YmlLoadError, "The '#{profile}' profile in cucumber.yml was a #{args_from_yml.class}. It must be a String or Array"
        end
        args_from_yml
      end

      def has_profile?(profile)
        cucumber_yml.has_key?(profile)
      end

      def cucumber_yml_defined?
        cucumber_file && File.exist?(cucumber_file)
      end

    private

      # Loads the profile, processing it through ERB and YAML, and returns it as a hash.
      def cucumber_yml
        return @cucumber_yml if @cucumber_yml
        unless cucumber_yml_defined?
          raise(ProfilesNotDefinedError,"cucumber.yml was not found.  Current directory is #{Dir.pwd}.  Please refer to cucumber's documentation on defining profiles in cucumber.yml.  You must define a 'default' profile to use the cucumber command without any arguments.\nType 'cucumber --help' for usage.\n")
        end

        require 'erb'
        require 'yaml'
        begin
          @cucumber_erb = ERB.new(IO.read(cucumber_file)).result(binding)
        rescue Exception => e
          raise(YmlLoadError,"cucumber.yml was found, but could not be parsed with ERB.  Please refer to cucumber's documentation on correct profile usage.\n#{$!.inspect}")
        end

        begin
          @cucumber_yml = YAML::load(@cucumber_erb)
        rescue StandardError => e
          raise(YmlLoadError,"cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        if @cucumber_yml.nil? || !@cucumber_yml.is_a?(Hash)
          raise(YmlLoadError,"cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        return @cucumber_yml
      end

      # Locates cucumber.yml file. The file can end in .yml or .yaml,
      # and be located in the current directory (eg. project root) or
      # in a .config/ or config/ subdirectory of the current directory.
      def cucumber_file
        @cucumber_file ||= Dir.glob('{,.config/,config/}cucumber{.yml,.yaml}').first
      end

    end
  end
end

