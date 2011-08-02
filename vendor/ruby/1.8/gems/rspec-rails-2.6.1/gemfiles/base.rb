module GemfileBase
  def self.extended(host)
    host.instance_eval do
      source "http://rubygems.org"

      %w[rspec rspec-core rspec-expectations rspec-mocks rspec-rails].each do |lib|
        library_path = File.expand_path("../../../#{lib}", __FILE__)
        if File.exist?(library_path)
          gem lib, :path => library_path
        elsif ENV["CI"] || ENV["USE_GIT_REPOS"]
          gem lib, :git => "git://github.com/rspec/#{lib}.git"
        else
          gem lib
        end
      end

      gem 'rake', '0.8.7'
      gem 'rdoc'
      gem 'sqlite3-ruby', :require => 'sqlite3'
      gem "cucumber", "~> 0.10.2"
      gem "aruba", "~> 0.3.6"
      gem "growl", "1.0.3"
      gem "ZenTest", "~> 4.4.2"

      # gem "webrat", "0.7.3"
      # gem "capybara", "~> 0.4"
      # gem "capybara", "1.0.0.beta1"

      unless ENV['CI']
        gem "rcov", "0.9.9"
        gem "relish", "0.2.0"
        gem "guard-rspec", "0.1.9"

        if RUBY_PLATFORM =~ /darwin/
          gem "autotest-fsevent", "~> 0.2.4"
          gem "autotest-growl", "~> 0.2.9"
        end

        platforms :mri_18 do
          gem 'ruby-debug'
        end

        platforms :mri_19 do
          gem 'linecache19', '0.5.11' # 0.5.12 cannot install on 1.9.1, and 0.5.11 appears to work with both 1.9.1 & 1.9.2
          gem 'ruby-debug19'
          gem 'ruby-debug-base19', RUBY_VERSION == '1.9.1' ? '0.11.23' : '~> 0.11.24'
        end

        platforms :ruby_18, :ruby_19 do
          gem "rb-fsevent", "~> 0.3.9"
          gem "ruby-prof", "~> 0.9.2"
        end
      end

      platforms :jruby do
        gem "jruby-openssl"
      end
    end
  end
end
