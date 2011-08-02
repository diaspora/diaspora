require File.expand_path('../lib/faraday_middleware/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'faraday_middleware'
  gem.summary = %q{Various middleware for Faraday}
  gem.description = gem.summary

  gem.homepage = 'https://github.com/pengwynn/faraday_middleware'

  gem.authors = ["Erik Michaels-Ober", "Wynn Netherland"]
  gem.email   = ['sferik@gmail.com', 'wynn.netherland@gmail.com']

  gem.version  = FaradayMiddleware::VERSION

  gem.require_paths = ['lib']
  gem.files = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')

  gem.add_runtime_dependency 'faraday', '~> 0.6.0'
  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'simplecov', '~> 0.4'
  gem.add_development_dependency 'rash', '~> 0.3'
  gem.add_development_dependency 'json_pure', '~> 1.5'
  gem.add_development_dependency 'multi_json', '~> 1.0'
  gem.add_development_dependency 'multi_xml', '~> 0.2'
  gem.add_development_dependency 'oauth2', '~> 0.2'
  gem.add_development_dependency 'simple_oauth', '~> 0.1'
end
