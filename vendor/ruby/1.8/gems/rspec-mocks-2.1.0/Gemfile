source "http://rubygems.org"

%w[rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end

gem "rake"
gem "cucumber", "0.8.5"
gem "aruba", "0.2.2"
gem "autotest"
gem "relish"

case RUBY_VERSION.to_s
when '1.9.2'
  gem "ruby-debug19"
when /^1.8/
  gem "ruby-debug"
end
