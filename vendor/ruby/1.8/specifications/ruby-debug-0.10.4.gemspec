# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-debug}
  s.version = "0.10.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kent Sibilev"]
  s.date = %q{2010-10-27}
  s.default_executable = %q{rdebug}
  s.description = %q{A generic command line interface for ruby-debug.
}
  s.email = %q{ksibilev@yahoo.com}
  s.executables = ["rdebug"]
  s.extra_rdoc_files = ["README"]
  s.files = ["AUTHORS", "CHANGES", "LICENSE", "README", "VERSION", "Rakefile", "cli/ruby-debug.rb", "cli/ruby-debug/processor.RB", "cli/ruby-debug/helper.rb", "cli/ruby-debug/debugger.rb", "cli/ruby-debug/commands/source.rb", "cli/ruby-debug/commands/set.rb", "cli/ruby-debug/commands/raise.RB", "cli/ruby-debug/commands/breakpoints.rb", "cli/ruby-debug/commands/list.rb", "cli/ruby-debug/commands/display.rb", "cli/ruby-debug/commands/continue.RB", "cli/ruby-debug/commands/trace.rb", "cli/ruby-debug/commands/frame.rb", "cli/ruby-debug/commands/show.rb", "cli/ruby-debug/commands/save.rb", "cli/ruby-debug/commands/variables.rb", "cli/ruby-debug/commands/threads.rb", "cli/ruby-debug/commands/disassemble.RB", "cli/ruby-debug/commands/irb.rb", "cli/ruby-debug/commands/tmate.rb", "cli/ruby-debug/commands/kill.rb", "cli/ruby-debug/commands/catchpoint.rb", "cli/ruby-debug/commands/quit.rb", "cli/ruby-debug/commands/method.rb", "cli/ruby-debug/commands/finish.rb", "cli/ruby-debug/commands/enable.rb", "cli/ruby-debug/commands/stepping.rb", "cli/ruby-debug/commands/edit.rb", "cli/ruby-debug/commands/help.rb", "cli/ruby-debug/commands/reload.rb", "cli/ruby-debug/commands/eval.rb", "cli/ruby-debug/commands/info.rb", "cli/ruby-debug/commands/continue.rb", "cli/ruby-debug/commands/source.RB", "cli/ruby-debug/commands/control.rb", "cli/ruby-debug/commands/condition.rb", "cli/ruby-debug/interface.rb", "cli/ruby-debug/command.rb", "cli/ruby-debug/processor.rb", "ChangeLog", "bin/rdebug", "doc/rdebug.1", "test/rdebug-save.1", "test/data/finish.cmd", "test/data/source.cmd", "test/data/enable.cmd", "test/data/ctrl.cmd", "test/data/annotate.cmd", "test/data/methodsig.cmd", "test/data/breakpoints.cmd", "test/data/linetracep.cmd", "test/data/stepping.cmd", "test/data/display.cmd", "test/data/except-bug1.cmd", "test/data/info-var.cmd", "test/data/info-thread.cmd", "test/data/emacs_basic.cmd", "test/data/post-mortem-next.cmd", "test/data/list.cmd", "test/data/info.cmd", "test/data/setshow.cmd", "test/data/catch.cmd", "test/data/break_bad.cmd", "test/data/quit.cmd", "test/data/method.cmd", "test/data/frame.cmd", "test/data/save.cmd", "test/data/raise.cmd", "test/data/break_loop_bug.cmd", "test/data/linetrace.cmd", "test/data/edit.cmd", "test/data/info-var-bug2.cmd", "test/data/output.cmd", "test/data/condition.cmd", "test/data/post-mortem.cmd", "test/data/help.cmd", "test/data/file-with-space.cmd", "test/data/pm-bug.cmd", "test/data/brkpt-class-bug.cmd", "test/data/dollar-0b.right", "test/data/catch.right", "test/data/dollar-0.right", "test/data/linetracep.right", "test/data/enable.right", "test/data/method.right", "test/data/save.right", "test/data/post-mortem-osx.right", "test/data/condition.right", "test/data/frame.right", "test/data/info.right", "test/data/linetrace.right", "test/data/post-mortem-next.right", "test/data/edit.right", "test/data/test-init-osx.right", "test/data/annotate.right", "test/data/test-init.right", "test/data/help.right", "test/data/post-mortem.right", "test/data/pm-bug.right", "test/data/ctrl.right", "test/data/trace.right", "test/data/output.right", "test/data/noquit.right", "test/data/test-init-cygwin.right", "test/data/file-with-space.right", "test/data/quit.right", "test/data/source.right", "test/data/info-var.right", "test/data/except-bug1.right", "test/data/info-thread.right", "test/data/emacs_basic.right", "test/data/break_loop_bug.right", "test/data/stepping.right", "test/data/methodsig.right", "test/data/dollar-0a.right", "test/data/raise.right", "test/data/history.right", "test/data/finish.right", "test/data/info-var-bug2.right", "test/data/breakpoints.right", "test/data/break_bad.right", "test/data/setshow.right", "test/data/brkpt-class-bug.right", "test/data/list.right", "test/data/display.right", "test/config.yaml", "test/test-condition.rb", "test/test-trace.rb", "test/null.rb", "test/test-enable.rb", "test/test-emacs-basic.rb", "test/classes.rb", "test/test-edit.rb", "test/info-var-bug.rb", "test/tdebug.rb", "test/test-save.rb", "test/pm.rb", "test/base/binding.rb", "test/base/reload_bug.rb", "test/base/catchpoint.rb", "test/base/base.rb", "test/base/load.rb", "test/cli/commands/catchpoint_test.rb", "test/cli/commands/unit/regexp.rb", "test/pm-bug.rb", "test/raise.rb", "test/thread1.rb", "test/test-source.rb", "test/test-raise.rb", "test/brkpt-class-bug.rb", "test/test-info-var.rb", "test/except-bug2.rb", "test/gcd-dbg-nox.rb", "test/test-ctrl.rb", "test/helper.rb", "test/test-frame.rb", "test/test-setshow.rb", "test/trunc-call.rb", "test/test-break-bad.rb", "test/bp_loop_issue.rb", "test/test-stepping.rb", "test/gcd.rb", "test/test-output.rb", "test/gcd-dbg.rb", "test/test-dollar-0.rb", "test/test-except-bug1.rb", "test/file with space.rb", "test/info-var-bug2.rb", "test/test-file-with-space.rb", "test/test-quit.rb", "test/except-bug1.rb", "test/tvar.rb", "test/dollar-0.rb", "test/pm-base.rb", "test/test-list.rb", "test/test-info-thread.rb", "test/test-finish.rb", "test/test-breakpoints.rb", "test/test-pm.rb", "test/test-help.rb", "test/test-init.rb", "test/test-method.rb", "test/test-hist.rb", "test/test-catch.rb", "test/scope-test.rb", "test/test-annotate.rb", "test/output.rb", "test/test-brkpt-class-bug.rb", "test/test-display.rb", "test/test-info.rb", "rdbg.rb", "runner.sh"]
  s.homepage = %q{http://rubyforge.org/projects/ruby-debug/}
  s.require_paths = ["cli"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubyforge_project = %q{ruby-debug}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Command line interface (CLI) for ruby-debug-base}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<columnize>, [">= 0.1"])
      s.add_runtime_dependency(%q<ruby-debug-base>, ["~> 0.10.4.0"])
    else
      s.add_dependency(%q<columnize>, [">= 0.1"])
      s.add_dependency(%q<ruby-debug-base>, ["~> 0.10.4.0"])
    end
  else
    s.add_dependency(%q<columnize>, [">= 0.1"])
    s.add_dependency(%q<ruby-debug-base>, ["~> 0.10.4.0"])
  end
end
