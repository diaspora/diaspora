module NewRelic
  class Control
    module Frameworks
      # A control used when no framework is detected - the default.
      # Looks for a newrelic.yml file in several locations including
      # ./, ./config, $HOME/.newrelic and $HOME/.  It loads the
      # settings from the newrelic.yml section based on the value of
      # RUBY_ENV or RAILS_ENV.
      class Ruby < NewRelic::Control

        def env
          @env ||= ENV['RUBY_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
        end
        def root
          @root ||= ENV['APP_ROOT'] || Dir['.']
        end
        # Check a sequence of file locations for newrelic.yml
        def config_file
          files = []
          files << File.join(root,"config","newrelic.yml")
          files << File.join(root,"newrelic.yml")
          if ENV["HOME"]
            files << File.join(ENV["HOME"], ".newrelic", "newrelic.yml")
            files << File.join(ENV["HOME"], "newrelic.yml")
          end
          files << File.expand_path(ENV["NRCONFIG"]) if ENV["NRCONFIG"]
          files.each do | file |
            return File.expand_path(file) if File.exists? file
          end
          return File.expand_path(files.first)
        end
        def to_stdout(msg)
          STDOUT.puts msg
        end

        def init_config(options={})
        end

      end
    end
  end
end
