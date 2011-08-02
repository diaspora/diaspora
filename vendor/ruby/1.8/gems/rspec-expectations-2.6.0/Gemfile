source "http://rubygems.org"

### rspec libs
%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  end
end

### dev dependencies
gem "rake", "0.8.7"
gem "cucumber", "~> 0.10.2"
gem "aruba", "~> 0.3.6"
gem "rcov", "0.9.9", :platforms => :mri
gem "relish", "0.2.0"
gem "guard-rspec", "0.1.9"
gem "growl", "1.0.3"
gem "nokogiri", "1.4.4"

platforms :mri_18 do
  gem 'ruby-debug'
end

platforms :mri_19 do
  gem 'linecache19', '0.5.11' # 0.5.12 cannot install on 1.9.1, and 0.5.11 appears to work with both 1.9.1 & 1.9.2
  gem 'ruby-debug19'
  gem 'ruby-debug-base19', RUBY_VERSION == '1.9.1' ? '0.11.23' : '~> 0.11.24'
end

platforms :mri_18, :mri_19 do
  gem "rb-fsevent", "~> 0.3.9"
  gem "ruby-prof", "~> 0.9.2"
end

platforms :jruby do
  gem "jruby-openssl"
end
