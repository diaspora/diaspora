source "http://rubygems.org"

%w[rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end

gem "rake"
gem "cucumber", "0.8.5"
gem "aruba", "0.2.2"
gem "autotest"
gem "watchr"
gem "rcov"
gem "mocha"
gem "rr"
gem "flexmock"
gem "nokogiri"
gem "syntax"
gem "relish", "~> 0.0.3"
gem "guard-rspec"
gem "growl"
gem "rb-fsevent"

unless RUBY_PLATFORM == "java"
  gem "ruby-prof"
  case RUBY_VERSION
  when /^1.9.2/
    gem "ruby-debug19"
  when /^1.8/
    gem "ruby-debug"
  end
end
