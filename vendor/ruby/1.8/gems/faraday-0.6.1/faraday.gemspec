## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'faraday'
  s.version           = '0.6.1'
  s.date              = '2011-04-13'
  s.rubyforge_project = 'faraday'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "HTTP/REST API client library."
  s.description = "HTTP/REST API client library."

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Rick Olson"]
  s.email    = 'technoweenie@gmail.com'
  s.homepage = 'http://github.com/technoweenie/faraday'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  s.add_development_dependency('rake', '~> 0.8')
  s.add_runtime_dependency('addressable', '~> 2.2.4')
  s.add_runtime_dependency('multipart-post', '~> 1.1.0')
  s.add_runtime_dependency('rack', ['>= 1.1.0', "< 2"])

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    LICENSE
    README.md
    Rakefile
    faraday.gemspec
    lib/faraday.rb
    lib/faraday/adapter.rb
    lib/faraday/adapter/action_dispatch.rb
    lib/faraday/adapter/em_synchrony.rb
    lib/faraday/adapter/excon.rb
    lib/faraday/adapter/net_http.rb
    lib/faraday/adapter/patron.rb
    lib/faraday/adapter/test.rb
    lib/faraday/adapter/typhoeus.rb
    lib/faraday/builder.rb
    lib/faraday/connection.rb
    lib/faraday/error.rb
    lib/faraday/middleware.rb
    lib/faraday/request.rb
    lib/faraday/request/json.rb
    lib/faraday/request/multipart.rb
    lib/faraday/request/url_encoded.rb
    lib/faraday/response.rb
    lib/faraday/response/logger.rb
    lib/faraday/response/raise_error.rb
    lib/faraday/upload_io.rb
    lib/faraday/utils.rb
    test/adapters/live_test.rb
    test/adapters/logger_test.rb
    test/adapters/net_http_test.rb
    test/adapters/test_middleware_test.rb
    test/connection_test.rb
    test/env_test.rb
    test/helper.rb
    test/live_server.rb
    test/middleware_stack_test.rb
    test/request_middleware_test.rb
    test/response_middleware_test.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/.*_test\.rb/ }
end
