# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capistrano}
  s.version = "2.5.19"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck", "Lee Hambley"]
  s.date = %q{2010-06-22}
  s.description = %q{Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH.}
  s.email = ["jamis@jamisbuck.org", "lee.hambley@gmail.com"]
  s.executables = ["capify", "cap"]
  s.extra_rdoc_files = ["README"]
  s.files = [".gitignore", "CHANGELOG", "README", "Rakefile", "VERSION", "bin/cap", "bin/capify", "lib/capistrano.rb", "lib/capistrano/callback.rb", "lib/capistrano/cli.rb", "lib/capistrano/cli/execute.rb", "lib/capistrano/cli/help.rb", "lib/capistrano/cli/help.txt", "lib/capistrano/cli/options.rb", "lib/capistrano/cli/ui.rb", "lib/capistrano/command.rb", "lib/capistrano/configuration.rb", "lib/capistrano/configuration/actions/file_transfer.rb", "lib/capistrano/configuration/actions/inspect.rb", "lib/capistrano/configuration/actions/invocation.rb", "lib/capistrano/configuration/callbacks.rb", "lib/capistrano/configuration/connections.rb", "lib/capistrano/configuration/execution.rb", "lib/capistrano/configuration/loading.rb", "lib/capistrano/configuration/namespaces.rb", "lib/capistrano/configuration/roles.rb", "lib/capistrano/configuration/servers.rb", "lib/capistrano/configuration/variables.rb", "lib/capistrano/errors.rb", "lib/capistrano/extensions.rb", "lib/capistrano/logger.rb", "lib/capistrano/processable.rb", "lib/capistrano/recipes/compat.rb", "lib/capistrano/recipes/deploy.rb", "lib/capistrano/recipes/deploy/dependencies.rb", "lib/capistrano/recipes/deploy/local_dependency.rb", "lib/capistrano/recipes/deploy/remote_dependency.rb", "lib/capistrano/recipes/deploy/scm.rb", "lib/capistrano/recipes/deploy/scm/accurev.rb", "lib/capistrano/recipes/deploy/scm/base.rb", "lib/capistrano/recipes/deploy/scm/bzr.rb", "lib/capistrano/recipes/deploy/scm/cvs.rb", "lib/capistrano/recipes/deploy/scm/darcs.rb", "lib/capistrano/recipes/deploy/scm/git.rb", "lib/capistrano/recipes/deploy/scm/mercurial.rb", "lib/capistrano/recipes/deploy/scm/none.rb", "lib/capistrano/recipes/deploy/scm/perforce.rb", "lib/capistrano/recipes/deploy/scm/subversion.rb", "lib/capistrano/recipes/deploy/strategy.rb", "lib/capistrano/recipes/deploy/strategy/base.rb", "lib/capistrano/recipes/deploy/strategy/checkout.rb", "lib/capistrano/recipes/deploy/strategy/copy.rb", "lib/capistrano/recipes/deploy/strategy/export.rb", "lib/capistrano/recipes/deploy/strategy/remote.rb", "lib/capistrano/recipes/deploy/strategy/remote_cache.rb", "lib/capistrano/recipes/deploy/templates/maintenance.rhtml", "lib/capistrano/recipes/standard.rb", "lib/capistrano/recipes/templates/maintenance.rhtml", "lib/capistrano/role.rb", "lib/capistrano/server_definition.rb", "lib/capistrano/shell.rb", "lib/capistrano/ssh.rb", "lib/capistrano/task_definition.rb", "lib/capistrano/transfer.rb", "lib/capistrano/version.rb", "test/cli/execute_test.rb", "test/cli/help_test.rb", "test/cli/options_test.rb", "test/cli/ui_test.rb", "test/cli_test.rb", "test/command_test.rb", "test/configuration/actions/file_transfer_test.rb", "test/configuration/actions/inspect_test.rb", "test/configuration/actions/invocation_test.rb", "test/configuration/callbacks_test.rb", "test/configuration/connections_test.rb", "test/configuration/execution_test.rb", "test/configuration/loading_test.rb", "test/configuration/namespace_dsl_test.rb", "test/configuration/roles_test.rb", "test/configuration/servers_test.rb", "test/configuration/variables_test.rb", "test/configuration_test.rb", "test/deploy/local_dependency_test.rb", "test/deploy/remote_dependency_test.rb", "test/deploy/scm/accurev_test.rb", "test/deploy/scm/base_test.rb", "test/deploy/scm/bzr_test.rb", "test/deploy/scm/darcs_test.rb", "test/deploy/scm/git_test.rb", "test/deploy/scm/mercurial_test.rb", "test/deploy/scm/none_test.rb", "test/deploy/scm/subversion_test.rb", "test/deploy/strategy/copy_test.rb", "test/extensions_test.rb", "test/fixtures/cli_integration.rb", "test/fixtures/config.rb", "test/fixtures/custom.rb", "test/logger_test.rb", "test/role_test.rb", "test/server_definition_test.rb", "test/shell_test.rb", "test/ssh_test.rb", "test/task_definition_test.rb", "test/transfer_test.rb", "test/utils.rb"]
  s.homepage = %q{http://github.com/capistrano/capistrano}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Capistrano – Welcome to easy deployment with Ruby over SSH}
  s.test_files = ["test/cli/execute_test.rb", "test/cli/help_test.rb", "test/cli/options_test.rb", "test/cli/ui_test.rb", "test/cli_test.rb", "test/command_test.rb", "test/configuration/actions/file_transfer_test.rb", "test/configuration/actions/inspect_test.rb", "test/configuration/actions/invocation_test.rb", "test/configuration/callbacks_test.rb", "test/configuration/connections_test.rb", "test/configuration/execution_test.rb", "test/configuration/loading_test.rb", "test/configuration/namespace_dsl_test.rb", "test/configuration/roles_test.rb", "test/configuration/servers_test.rb", "test/configuration/variables_test.rb", "test/configuration_test.rb", "test/deploy/local_dependency_test.rb", "test/deploy/remote_dependency_test.rb", "test/deploy/scm/accurev_test.rb", "test/deploy/scm/base_test.rb", "test/deploy/scm/bzr_test.rb", "test/deploy/scm/darcs_test.rb", "test/deploy/scm/git_test.rb", "test/deploy/scm/mercurial_test.rb", "test/deploy/scm/none_test.rb", "test/deploy/scm/subversion_test.rb", "test/deploy/strategy/copy_test.rb", "test/extensions_test.rb", "test/fixtures/cli_integration.rb", "test/fixtures/config.rb", "test/fixtures/custom.rb", "test/logger_test.rb", "test/role_test.rb", "test/server_definition_test.rb", "test/shell_test.rb", "test/ssh_test.rb", "test/task_definition_test.rb", "test/transfer_test.rb", "test/utils.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net-ssh>, [">= 2.0.14"])
      s.add_runtime_dependency(%q<net-sftp>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<net-scp>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<net-ssh-gateway>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<net-ssh>, [">= 2.0.14"])
      s.add_dependency(%q<net-sftp>, [">= 2.0.0"])
      s.add_dependency(%q<net-scp>, [">= 1.0.0"])
      s.add_dependency(%q<net-ssh-gateway>, [">= 1.0.0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 2.0.14"])
    s.add_dependency(%q<net-sftp>, [">= 2.0.0"])
    s.add_dependency(%q<net-scp>, [">= 1.0.0"])
    s.add_dependency(%q<net-ssh-gateway>, [">= 1.0.0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
