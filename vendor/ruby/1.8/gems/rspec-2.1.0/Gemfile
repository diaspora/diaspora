source :rubygems

gem "rake"

%w[rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end
