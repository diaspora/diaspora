# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{resque}
  s.version = "1.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Wanstrath"]
  s.date = %q{2010-08-23}
  s.description = %q{    Resque is a Redis-backed Ruby library for creating background jobs,
    placing those jobs on multiple queues, and processing them later.

    Background jobs can be any Ruby class or module that responds to
    perform. Your existing classes can easily be converted to background
    jobs or you can create new classes specifically to do work. Or, you
    can do both.

    Resque is heavily inspired by DelayedJob (which rocks) and is
    comprised of three parts:

    * A Ruby library for creating, querying, and processing jobs
    * A Rake task for starting a worker which processes jobs
    * A Sinatra app for monitoring queues, jobs, and workers.
}
  s.email = %q{chris@ozmm.org}
  s.executables = ["resque", "resque-web"]
  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.files = ["README.markdown", "Rakefile", "LICENSE", "HISTORY.md", "lib/resque/errors.rb", "lib/resque/failure/base.rb", "lib/resque/failure/hoptoad.rb", "lib/resque/failure/multiple.rb", "lib/resque/failure/redis.rb", "lib/resque/failure.rb", "lib/resque/helpers.rb", "lib/resque/job.rb", "lib/resque/plugin.rb", "lib/resque/server/public/idle.png", "lib/resque/server/public/jquery-1.3.2.min.js", "lib/resque/server/public/jquery.relatize_date.js", "lib/resque/server/public/poll.png", "lib/resque/server/public/ranger.js", "lib/resque/server/public/reset.css", "lib/resque/server/public/style.css", "lib/resque/server/public/working.png", "lib/resque/server/test_helper.rb", "lib/resque/server/views/error.erb", "lib/resque/server/views/failed.erb", "lib/resque/server/views/key_sets.erb", "lib/resque/server/views/key_string.erb", "lib/resque/server/views/layout.erb", "lib/resque/server/views/next_more.erb", "lib/resque/server/views/overview.erb", "lib/resque/server/views/queues.erb", "lib/resque/server/views/stats.erb", "lib/resque/server/views/workers.erb", "lib/resque/server/views/working.erb", "lib/resque/server.rb", "lib/resque/stat.rb", "lib/resque/tasks.rb", "lib/resque/version.rb", "lib/resque/worker.rb", "lib/resque.rb", "bin/resque", "bin/resque-web", "test/job_hooks_test.rb", "test/job_plugins_test.rb", "test/plugin_test.rb", "test/redis-test.conf", "test/resque-web_test.rb", "test/resque_test.rb", "test/test_helper.rb", "test/worker_test.rb", "tasks/redis.rake", "tasks/resque.rake"]
  s.homepage = %q{http://github.com/defunkt/resque}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Resque is a Redis-backed queueing system.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<redis-namespace>, ["~> 0.8.0"])
      s.add_runtime_dependency(%q<vegas>, ["~> 0.1.2"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_runtime_dependency(%q<json>, ["~> 1.4.6"])
    else
      s.add_dependency(%q<redis-namespace>, ["~> 0.8.0"])
      s.add_dependency(%q<vegas>, ["~> 0.1.2"])
      s.add_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_dependency(%q<json>, ["~> 1.4.6"])
    end
  else
    s.add_dependency(%q<redis-namespace>, ["~> 0.8.0"])
    s.add_dependency(%q<vegas>, ["~> 0.1.2"])
    s.add_dependency(%q<sinatra>, [">= 0.9.2"])
    s.add_dependency(%q<json>, ["~> 1.4.6"])
  end
end
