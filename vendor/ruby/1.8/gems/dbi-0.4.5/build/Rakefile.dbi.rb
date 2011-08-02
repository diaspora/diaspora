require 'rake_task_lib'
require 'dbi'

DBD_PACKAGES = Dir['lib/dbd/*.rb'].collect { |x| File.basename(x, '.rb') }

# creates a number of tasks like dbi:task_name, dbd_mysql:task_name, so on.
# Builds these out into an array that can be used as a prereq for other tasks.
def map_task(task_name)
    namespaces = (['dbi'] + DBD_PACKAGES.collect { |x| dbd_namespace(x) }).flatten
    namespaces.collect { |x| [x, task_name].join(":") }
end

task :package         => (map_task("package") + map_task("gem"))
task :clobber_package => map_task("clobber_package")

desc 'Run interface tests (no database connectivity required)'
task :test_dbi do
    ruby("test/ts_dbi.rb")
end

desc 'Run database-specific tests'
task :test_dbd do
    ruby("test/ts_dbd.rb")
end

desc 'Run full test suite'
task :test => [:test_dbi, :test_dbd]

build_dbi_tasks

#
# There's probably a better way to do this, but here's a boilerplate spec that we dup and modify.
#

task :dbi => DEFAULT_TASKS.collect { |x| "dbi:#{x.to_s}" }

namespace :dbi do
    code_files = %w(examples/**/* bin/dbi build/Rakefile.dbi.rb lib/dbi.rb lib/dbi/**/*.rb test/ts_dbi.rb test/dbi/*)

    spec = boilerplate_spec
    spec.name        = 'dbi'
    spec.version     = DBI::VERSION
    spec.test_file   = 'test/ts_dbi.rb'
    spec.executables = ['dbi', 'test_broken_dbi']
    spec.files       = gem_files(code_files)
    spec.summary     = 'A vendor independent interface for accessing databases, similar to Perl\'s DBI'
    spec.description = 'A vendor independent interface for accessing databases, similar to Perl\'s DBI'
    spec.add_dependency 'deprecated', '= 2.0.1'

    build_package_tasks(spec, code_files)
end

DBD_PACKAGES.each do |dbd|
    my_namespace = dbd_namespace(dbd)

    task my_namespace => DEFAULT_TASKS.collect { |x| "#{my_namespace}:#{x.to_s}" }
    namespace my_namespace do
        build_dbd_tasks(dbd)
    end
end
