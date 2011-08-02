require 'open-uri'
require 'active_support/deprecation'
require 'rbconfig'

module Rails
  module Generators
    module Actions

      # Install a plugin. You must provide either a Subversion url or Git url.
      #
      # For a Git-hosted plugin, you can specify a branch and
      # whether it should be added as a submodule instead of cloned.
      #
      # For a Subversion-hosted plugin you can specify a revision.
      #
      # ==== Examples
      #
      #   plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
      #   plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :branch => 'stable'
      #   plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
      #   plugin 'restful-authentication', :svn => 'svn://svnhub.com/technoweenie/restful-authentication/trunk'
      #   plugin 'restful-authentication', :svn => 'svn://svnhub.com/technoweenie/restful-authentication/trunk', :revision => 1234
      #
      def plugin(name, options)
        log :plugin, name

        if options[:git] && options[:submodule]
          options[:git] = "-b #{options[:branch]} #{options[:git]}" if options[:branch]
          in_root do
            run "git submodule add #{options[:git]} vendor/plugins/#{name}", :verbose => false
          end
        elsif options[:git] || options[:svn]
          options[:git] = "-b #{options[:branch]} #{options[:git]}"   if options[:branch]
          options[:svn] = "-r #{options[:revision]} #{options[:svn]}" if options[:revision]
          in_root do
            run_ruby_script "script/rails plugin install #{options[:svn] || options[:git]}", :verbose => false
          end
        else
          log "! no git or svn provided for #{name}. Skipping..."
        end
      end

      # Adds an entry into Gemfile for the supplied gem. If env
      # is specified, add the gem to the given environment.
      #
      # ==== Example
      #
      #   gem "rspec", :group => :test
      #   gem "technoweenie-restful-authentication", :lib => "restful-authentication", :source => "http://gems.github.com/"
      #   gem "rails", "3.0", :git => "git://github.com/rails/rails"
      #
      def gem(*args)
        options = args.extract_options!
        name, version = args

        # Deal with deprecated options
        { :env => :group, :only => :group,
          :lib => :require, :require_as => :require }.each do |old, new|
          next unless options[old]
          options[new] = options.delete(old)
          ActiveSupport::Deprecation.warn "#{old.inspect} option in gem is deprecated, use #{new.inspect} instead"
        end

        # Deal with deprecated source
        if source = options.delete(:source)
          ActiveSupport::Deprecation.warn ":source option in gem is deprecated, use add_source method instead"
          add_source(source)
        end

        # Set the message to be shown in logs. Uses the git repo if one is given,
        # otherwise use name (version).
        parts, message = [ name.inspect ], name
        if version ||= options.delete(:version)
          parts   << version.inspect
          message << " (#{version})"
        end
        message = options[:git] if options[:git]

        log :gemfile, message

        options.each do |option, value|
          parts << ":#{option} => #{value.inspect}"
        end

        in_root do
          append_file "Gemfile", "gem #{parts.join(", ")}\n", :verbose => false
        end
      end

      # Add the given source to Gemfile
      #
      # ==== Example
      #
      #   add_source "http://gems.github.com/"
      def add_source(source, options={})
        log :source, source

        in_root do
          prepend_file "Gemfile", "source #{source.inspect}\n", :verbose => false
        end
      end

      # Adds a line inside the Application class for config/application.rb.
      #
      # If options :env is specified, the line is appended to the corresponding
      # file in config/environments.
      #
      def environment(data=nil, options={}, &block)
        sentinel = /class [a-z_:]+ < Rails::Application/i
        data = block.call if !data && block_given?

        in_root do
          if options[:env].nil?
            inject_into_file 'config/application.rb', "\n  #{data}", :after => sentinel, :verbose => false
          else
            Array.wrap(options[:env]).each do|env|
              append_file "config/environments/#{env}.rb", "\n#{data}", :verbose => false
            end
          end
        end
      end
      alias :application :environment

      # Run a command in git.
      #
      # ==== Examples
      #
      #   git :init
      #   git :add => "this.file that.rb"
      #   git :add => "onefile.rb", :rm => "badfile.cxx"
      #
      def git(command={})
        if command.is_a?(Symbol)
          run "git #{command}"
        else
          command.each do |command, options|
            run "git #{command} #{options}"
          end
        end
      end

      # Create a new file in the vendor/ directory. Code can be specified
      # in a block or a data string can be given.
      #
      # ==== Examples
      #
      #   vendor("sekrit.rb") do
      #     sekrit_salt = "#{Time.now}--#{3.years.ago}--#{rand}--"
      #     "salt = '#{sekrit_salt}'"
      #   end
      #
      #   vendor("foreign.rb", "# Foreign code is fun")
      #
      def vendor(filename, data=nil, &block)
        log :vendor, filename
        create_file("vendor/#{filename}", data, :verbose => false, &block)
      end

      # Create a new file in the lib/ directory. Code can be specified
      # in a block or a data string can be given.
      #
      # ==== Examples
      #
      #   lib("crypto.rb") do
      #     "crypted_special_value = '#{rand}--#{Time.now}--#{rand(1337)}--'"
      #   end
      #
      #   lib("foreign.rb", "# Foreign code is fun")
      #
      def lib(filename, data=nil, &block)
        log :lib, filename
        create_file("lib/#{filename}", data, :verbose => false, &block)
      end

      # Create a new Rakefile with the provided code (either in a block or a string).
      #
      # ==== Examples
      #
      #   rakefile("bootstrap.rake") do
      #     project = ask("What is the UNIX name of your project?")
      #
      #     <<-TASK
      #       namespace :#{project} do
      #         task :bootstrap do
      #           puts "i like boots!"
      #         end
      #       end
      #     TASK
      #   end
      #
      #   rakefile("seed.rake", "puts 'im plantin ur seedz'")
      #
      def rakefile(filename, data=nil, &block)
        log :rakefile, filename
        create_file("lib/tasks/#{filename}", data, :verbose => false, &block)
      end

      # Create a new initializer with the provided code (either in a block or a string).
      #
      # ==== Examples
      #
      #   initializer("globals.rb") do
      #     data = ""
      #
      #     ['MY_WORK', 'ADMINS', 'BEST_COMPANY_EVAR'].each do
      #       data << "#{const} = :entp"
      #     end
      #
      #     data
      #   end
      #
      #   initializer("api.rb", "API_KEY = '123456'")
      #
      def initializer(filename, data=nil, &block)
        log :initializer, filename
        create_file("config/initializers/#{filename}", data, :verbose => false, &block)
      end

      # Generate something using a generator from Rails or a plugin.
      # The second parameter is the argument string that is passed to
      # the generator or an Array that is joined.
      #
      # ==== Example
      #
      #   generate(:authenticated, "user session")
      #
      def generate(what, *args)
        log :generate, what
        argument = args.map {|arg| arg.to_s }.flatten.join(" ")

        in_root { run_ruby_script("script/rails generate #{what} #{argument}", :verbose => false) }
      end

      # Runs the supplied rake task
      #
      # ==== Example
      #
      #   rake("db:migrate")
      #   rake("db:migrate", :env => "production")
      #   rake("gems:install", :sudo => true)
      #
      def rake(command, options={})
        log :rake, command
        env  = options[:env] || 'development'
        sudo = options[:sudo] && RbConfig::CONFIG['host_os'] !~ /mswin|mingw/ ? 'sudo ' : ''
        in_root { run("#{sudo}#{extify(:rake)} #{command} RAILS_ENV=#{env}", :verbose => false) }
      end

      # Just run the capify command in root
      #
      # ==== Example
      #
      #   capify!
      #
      def capify!
        log :capify, ""
        in_root { run("#{extify(:capify)} .", :verbose => false) }
      end

      # Add Rails to /vendor/rails
      #
      # ==== Example
      #
      #   freeze!
      #
      def freeze!(args={})
        ActiveSupport::Deprecation.warn "freeze! is deprecated since your rails app now comes bundled with Rails by default, please check your Gemfile"
      end

      # Make an entry in Rails routing file config/routes.rb
      #
      # === Example
      #
      #   route "root :to => 'welcome'"
      #
      def route(routing_code)
        log :route, routing_code
        sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/

        in_root do
          inject_into_file 'config/routes.rb', "\n  #{routing_code}\n", { :after => sentinel, :verbose => false }
        end
      end

      # Reads the given file at the source root and prints it in the console.
      #
      # === Example
      #
      #   readme "README"
      #
      def readme(path)
        log File.read(find_in_source_paths(path))
      end

      protected

        # Define log for backwards compatibility. If just one argument is sent,
        # invoke say, otherwise invoke say_status. Differently from say and
        # similarly to say_status, this method respects the quiet? option given.
        #
        def log(*args)
          if args.size == 1
            say args.first.to_s unless options.quiet?
          else
            args << (self.behavior == :invoke ? :green : :red)
            say_status *args
          end
        end

        # Add an extension to the given name based on the platform.
        #
        def extify(name)
          if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
            "#{name}.bat"
          else
            name
          end
        end

    end
  end
end
