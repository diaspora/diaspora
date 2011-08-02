# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{daemons}
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Uehlinger"]
  s.date = %q{2011-06-17}
  s.description = %q{Daemons provides an easy way to wrap existing ruby scripts (for example a self-written server)  to be run as a daemon and to be controlled by simple start/stop/restart commands.  You can also call blocks as daemons and control them from the parent or just daemonize the current process.  Besides this basic functionality, daemons offers many advanced features like exception  backtracing and logging (in case your ruby script crashes) and monitoring and automatic restarting of your processes if they crash.}
  s.email = %q{th.uehlinger@gmx.ch}
  s.extra_rdoc_files = ["README", "Releases", "TODO"]
  s.files = ["Rakefile", "Releases", "TODO", "README", "LICENSE", "setup.rb", "lib/daemons.rb", "lib/daemons/monitor.rb", "lib/daemons/application_group.rb", "lib/daemons/etc_extension.rb", "lib/daemons/daemonize.rb", "lib/daemons/cmdline.rb", "lib/daemons/controller.rb", "lib/daemons/change_privilege.rb", "lib/daemons/application.rb", "lib/daemons/pidmem.rb", "lib/daemons/pid.rb", "lib/daemons/pidfile.rb", "lib/daemons/exceptions.rb", "examples/run/ctrl_normal.rb", "examples/run/ctrl_monitor.rb", "examples/run/ctrl_proc.rb", "examples/run/ctrl_multiple.rb", "examples/run/ctrl_optionparser.rb", "examples/run/myserver.rb", "examples/run/myserver_hanging.rb", "examples/run/ctrl_exit.rb", "examples/run/myserver_crashing.rb", "examples/run/ctrl_proc_multiple.rb", "examples/run/ctrl_keep_pid_files.rb", "examples/run/ctrl_proc_simple.rb", "examples/run/ctrl_ontop.rb", "examples/run/ctrl_crash.rb", "examples/run/ctrl_exec.rb", "examples/run/ctrl_hanging.rb", "examples/run/myserver_exiting.rb", "examples/call/call.rb", "examples/call/call_monitor.rb", "examples/daemonize/daemonize.rb"]
  s.homepage = %q{http://daemons.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{daemons}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A toolkit to create and control daemons in different ways}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
