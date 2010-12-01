# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thin}
  s.version = "1.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marc-Andre Cournoyer"]
  s.date = %q{2010-03-01}
  s.default_executable = %q{thin}
  s.description = %q{A thin and fast web server}
  s.email = %q{macournoyer@gmail.com}
  s.executables = ["thin"]
  s.extensions = ["ext/thin_parser/extconf.rb"]
  s.files = ["COPYING", "CHANGELOG", "README", "Rakefile", "benchmark/abc", "benchmark/benchmarker.rb", "benchmark/runner", "bin/thin", "example/adapter.rb", "example/async_app.ru", "example/async_chat.ru", "example/async_tailer.ru", "example/config.ru", "example/monit_sockets", "example/monit_unixsock", "example/myapp.rb", "example/ramaze.ru", "example/thin.god", "example/thin_solaris_smf.erb", "example/thin_solaris_smf.readme.txt", "example/vlad.rake", "lib/rack/adapter/loader.rb", "lib/rack/adapter/rails.rb", "lib/thin/backends/base.rb", "lib/thin/backends/swiftiply_client.rb", "lib/thin/backends/tcp_server.rb", "lib/thin/backends/unix_server.rb", "lib/thin/command.rb", "lib/thin/connection.rb", "lib/thin/controllers/cluster.rb", "lib/thin/controllers/controller.rb", "lib/thin/controllers/service.rb", "lib/thin/controllers/service.sh.erb", "lib/thin/daemonizing.rb", "lib/thin/headers.rb", "lib/thin/logging.rb", "lib/thin/request.rb", "lib/thin/response.rb", "lib/thin/runner.rb", "lib/thin/server.rb", "lib/thin/stats.html.erb", "lib/thin/stats.rb", "lib/thin/statuses.rb", "lib/thin/version.rb", "lib/thin.rb", "spec/backends/swiftiply_client_spec.rb", "spec/backends/tcp_server_spec.rb", "spec/backends/unix_server_spec.rb", "spec/command_spec.rb", "spec/configs/cluster.yml", "spec/configs/single.yml", "spec/connection_spec.rb", "spec/controllers/cluster_spec.rb", "spec/controllers/controller_spec.rb", "spec/controllers/service_spec.rb", "spec/daemonizing_spec.rb", "spec/headers_spec.rb", "spec/logging_spec.rb", "spec/perf/request_perf_spec.rb", "spec/perf/response_perf_spec.rb", "spec/perf/server_perf_spec.rb", "spec/rack/loader_spec.rb", "spec/rack/rails_adapter_spec.rb", "spec/rails_app/app/controllers/application.rb", "spec/rails_app/app/controllers/simple_controller.rb", "spec/rails_app/app/helpers/application_helper.rb", "spec/rails_app/app/views/simple/index.html.erb", "spec/rails_app/config/boot.rb", "spec/rails_app/config/environment.rb", "spec/rails_app/config/environments/development.rb", "spec/rails_app/config/environments/production.rb", "spec/rails_app/config/environments/test.rb", "spec/rails_app/config/initializers/inflections.rb", "spec/rails_app/config/initializers/mime_types.rb", "spec/rails_app/config/routes.rb", "spec/rails_app/public/404.html", "spec/rails_app/public/422.html", "spec/rails_app/public/500.html", "spec/rails_app/public/dispatch.cgi", "spec/rails_app/public/dispatch.fcgi", "spec/rails_app/public/dispatch.rb", "spec/rails_app/public/favicon.ico", "spec/rails_app/public/images/rails.png", "spec/rails_app/public/index.html", "spec/rails_app/public/javascripts/application.js", "spec/rails_app/public/javascripts/controls.js", "spec/rails_app/public/javascripts/dragdrop.js", "spec/rails_app/public/javascripts/effects.js", "spec/rails_app/public/javascripts/prototype.js", "spec/rails_app/public/robots.txt", "spec/rails_app/script/about", "spec/rails_app/script/console", "spec/rails_app/script/destroy", "spec/rails_app/script/generate", "spec/rails_app/script/performance/benchmarker", "spec/rails_app/script/performance/profiler", "spec/rails_app/script/performance/request", "spec/rails_app/script/plugin", "spec/rails_app/script/process/inspector", "spec/rails_app/script/process/reaper", "spec/rails_app/script/process/spawner", "spec/rails_app/script/runner", "spec/rails_app/script/server", "spec/request/mongrel_spec.rb", "spec/request/parser_spec.rb", "spec/request/persistent_spec.rb", "spec/request/processing_spec.rb", "spec/response_spec.rb", "spec/runner_spec.rb", "spec/server/builder_spec.rb", "spec/server/pipelining_spec.rb", "spec/server/robustness_spec.rb", "spec/server/stopping_spec.rb", "spec/server/swiftiply.yml", "spec/server/swiftiply_spec.rb", "spec/server/tcp_spec.rb", "spec/server/threaded_spec.rb", "spec/server/unix_socket_spec.rb", "spec/server_spec.rb", "spec/spec_helper.rb", "tasks/announce.rake", "tasks/deploy.rake", "tasks/email.erb", "tasks/gem.rake", "tasks/rdoc.rake", "tasks/site.rake", "tasks/spec.rake", "tasks/stats.rake", "ext/thin_parser/ext_help.h", "ext/thin_parser/parser.h", "ext/thin_parser/parser.c", "ext/thin_parser/thin.c", "ext/thin_parser/extconf.rb", "ext/thin_parser/common.rl", "ext/thin_parser/parser.rl"]
  s.homepage = %q{http://code.macournoyer.com/thin/}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.5")
  s.rubyforge_project = %q{thin}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A thin and fast web server}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.6"])
      s.add_runtime_dependency(%q<daemons>, [">= 1.0.9"])
    else
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.6"])
      s.add_dependency(%q<daemons>, [">= 1.0.9"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.6"])
    s.add_dependency(%q<daemons>, [">= 1.0.9"])
  end
end
