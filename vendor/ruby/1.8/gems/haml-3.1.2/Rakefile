# ----- Utility Functions -----

def scope(path)
  File.join(File.dirname(__FILE__), path)
end

# ----- Benchmarking -----

desc <<END
Benchmark haml against ERb.
  TIMES=n sets the number of runs. Defaults to 1000.
END
task :benchmark do
  sh "ruby test/benchmark.rb #{ENV['TIMES']}"
end

# ----- Default: Testing ------

if ENV["RUN_CODE_RUN"] == "true"
  task :default => :"test:rails_compatibility"
else
  task :default => :test
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  test_files = FileList[scope('test/**/*_test.rb')]
  test_files.exclude(scope('test/rails/*'))
  test_files.exclude(scope('test/plugins/*'))
  test_files.exclude(scope('test/haml/spec/*'))
  t.test_files = test_files
  t.verbose = true
end
Rake::Task[:test].send(:add_comment, <<END)
To run with an alternate version of Rails, make test/rails a symlink to that version.
END

# ----- Packaging -----

# Don't use Rake::GemPackageTast because we want prerequisites to run
# before we load the gemspec.
desc "Build all the packages."
task :package => [:revision_file, :submodules, :permissions] do
  version = get_version
  File.open(scope('VERSION'), 'w') {|f| f.puts(version)}
  load scope('haml.gemspec')
  Gem::Builder.new(HAML_GEMSPEC).build
  sh %{git checkout VERSION}

  pkg = "#{HAML_GEMSPEC.name}-#{HAML_GEMSPEC.version}"
  mkdir_p "pkg"
  verbose(true) {mv "#{pkg}.gem", "pkg/#{pkg}.gem"}

  sh %{rm -f pkg/#{pkg}.tar.gz}
  verbose(false) {HAML_GEMSPEC.files.each {|f| sh %{tar rf pkg/#{pkg}.tar #{f}}}}
  sh %{gzip pkg/#{pkg}.tar}
end

task :permissions do
  sh %{chmod -R a+rx bin}
  sh %{chmod -R a+r .}
  require 'shellwords'
  Dir.glob('test/**/*_test.rb') do |file|
    next if file =~ %r{^test/haml/spec/}
    sh %{chmod a+rx #{file}}
  end
end

task :revision_file do
  require 'lib/haml'

  release = Rake.application.top_level_tasks.include?('release') || File.exist?(scope('EDGE_GEM_VERSION'))
  if Haml.version[:rev] && !release
    File.open(scope('REVISION'), 'w') { |f| f.puts Haml.version[:rev] }
  elsif release
    File.open(scope('REVISION'), 'w') { |f| f.puts "(release)" }
  else
    File.open(scope('REVISION'), 'w') { |f| f.puts "(unknown)" }
  end
end

# We also need to get rid of this file after packaging.
at_exit { File.delete(scope('REVISION')) rescue nil }

desc "Install Haml as a gem. Use SUDO=1 to install with sudo."
task :install => [:package] do
  gem  = RUBY_PLATFORM =~ /java/  ? 'jgem' : 'gem' 
  sh %{#{'sudo ' if ENV["SUDO"]}#{gem} install --no-ri pkg/haml-#{get_version}}
end

desc "Release a new Haml package to Rubyforge."
task :release => [:check_release, :package] do
  name = File.read(scope("VERSION_NAME")).strip
  version = File.read(scope("VERSION")).strip
  sh %{rubyforge add_release haml haml "#{name} (v#{version})" pkg/haml-#{version}.gem}
  sh %{rubyforge add_file    haml haml "#{name} (v#{version})" pkg/haml-#{version}.tar.gz}
  sh %{gem push pkg/haml-#{version}.gem}
end


# Ensures that the VERSION file has been updated for a new release.
task :check_release do
  version = File.read(scope("VERSION")).strip
  raise "There have been changes since current version (#{version})" if changed_since?(version)
  raise "VERSION_NAME must not be 'Bleeding Edge'" if File.read(scope("VERSION_NAME")) == "Bleeding Edge"
end

# Reads a password from the command line.
#
# @param name [String] The prompt to use to read the password
def read_password(prompt)
  require 'readline'
  system "stty -echo"
  Readline.readline("#{prompt}: ").strip
ensure
  system "stty echo"
  puts
end

# Returns whether or not the repository, or specific files,
# has/have changed since a given revision.
#
# @param rev [String] The revision to check against
# @param files [Array<String>] The files to check.
#   If this is empty, checks the entire repository
def changed_since?(rev, *files)
  IO.popen("git diff --exit-code #{rev} #{files.join(' ')}") {}
  return !$?.success?
end

task :submodules do
  if File.exist?(File.dirname(__FILE__) + "/.git")
    sh %{git submodule sync}
    sh %{git submodule update --init --recursive}
  end
end

task :release_edge do
  ensure_git_cleanup do
    puts "#{'=' * 50} Running rake release_edge"

    sh %{git checkout master}
    sh %{git reset --hard origin/master}
    sh %{rake package}
    version = get_version
    sh %{rubyforge add_release haml haml "Bleeding Edge (v#{version})" pkg/haml-#{version}.gem}
    sh %{gem push pkg/haml-#{version}.gem}
  end
end

# Get the version string. If this is being installed from Git,
# this includes the proper prerelease version.
def get_version
  written_version = File.read(scope('VERSION').strip)
  return written_version unless File.exist?(scope('.git'))

  # Get the current master branch version
  version = written_version.split('.')
  version.map! {|n| n =~ /^[0-9]+$/ ? n.to_i : n}
  return written_version unless version.size == 5 && version[3] == "alpha" # prerelease

  return written_version if (commit_count = `git log --pretty=oneline --first-parent stable.. | wc -l`).empty?
  version[4] = commit_count.strip
  version.join('.')
end

task :watch_for_update do
  sh %{ruby extra/update_watch.rb}
end

# ----- Documentation -----

task :rdoc do
  puts '=' * 100, <<END, '=' * 100
Haml uses the YARD documentation system (http://github.com/lsegal/yard).
Install the yard gem and then run "rake doc".
END
end

begin
  require 'yard'

  namespace :doc do
    task :sass do
      require 'sass'
      Dir[scope("yard/default/**/*.sass")].each do |sass|
        File.open(sass.gsub(/sass$/, 'css'), 'w') do |f|
          f.write(Sass::Engine.new(File.read(sass)).render)
        end
      end
    end

    desc "List all undocumented methods and classes."
    task :undocumented do
      opts = ENV["YARD_OPTS"] || ""
      ENV["YARD_OPTS"] = opts.dup + <<OPTS
 --list --query "
  object.docstring.blank? &&
  !(object.type == :method && object.is_alias?)"
OPTS
      Rake::Task['yard'].execute
    end
  end

  YARD::Rake::YardocTask.new do |t|
    t.files = FileList.new(scope('lib/**/*.rb')) do |list|
      list.exclude('lib/haml/template/patch.rb')
      list.exclude('lib/haml/template/plugin.rb')
      list.exclude('lib/haml/railtie.rb')
      list.exclude('lib/haml/helpers/action_view_mods.rb')
      list.exclude('lib/haml/helpers/xss_mods.rb')
    end.to_a
    t.options << '--incremental' if Rake.application.top_level_tasks.include?('redoc')
    t.options += FileList.new(scope('yard/*.rb')).to_a.map {|f| ['-e', f]}.flatten
    files = FileList.new(scope('doc-src/*')).to_a.sort_by {|s| s.size} + %w[MIT-LICENSE VERSION]
    t.options << '--files' << files.join(',')
    t.options << '--template-path' << scope('yard')
    t.options << '--title' << ENV["YARD_TITLE"] if ENV["YARD_TITLE"]

    t.before = lambda do
      if ENV["YARD_OPTS"]
        require 'shellwords'
        t.options.concat(Shellwords.shellwords(ENV["YARD_OPTS"]))
      end
    end
  end
  Rake::Task['yard'].prerequisites.insert(0, 'doc:sass')
  Rake::Task['yard'].instance_variable_set('@comment', nil)

  desc "Generate Documentation"
  task :doc => :yard
  task :redoc => :yard
rescue LoadError
  desc "Generate Documentation"
  task :doc => :rdoc
  task :yard => :rdoc
end

task :pages do
  puts "#{'=' * 50} Running rake pages"
  ensure_git_cleanup do
    sh %{git checkout haml-pages}
    sh %{git reset --hard origin/haml-pages}

    Dir.chdir("/var/www/haml-pages") do
      sh %{git fetch origin}

      sh %{git checkout stable}
      sh %{git reset --hard origin/stable}

      sh %{git checkout haml-pages}
      sh %{git reset --hard origin/haml-pages}
      sh %{rake build --trace}
      sh %{mkdir -p tmp}
      sh %{touch tmp/restart.txt}
    end
  end
end

# ----- Coverage -----

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.test_files = FileList[scope('test/**/*_test.rb')]
    t.rcov_opts << '-x' << '"^\/"'
    if ENV['NON_NATIVE']
      t.rcov_opts << "--no-rcovrt"
    end
    t.verbose = true
  end
rescue LoadError; end

# ----- Profiling -----

begin
  require 'ruby-prof'

  desc <<END
Run a profile of haml.
  TIMES=n sets the number of runs. Defaults to 1000.
  FILE=str sets the file to profile. Defaults to 'standard'
  OUTPUT=str sets the ruby-prof output format.
    Can be Flat, CallInfo, or Graph. Defaults to Flat. Defaults to Flat.
END
  task :profile do
    times  = (ENV['TIMES'] || '1000').to_i
    file   = ENV['FILE']

    require 'lib/haml'

    file = File.read(scope("test/haml/templates/#{file || 'standard'}.haml"))
    obj = Object.new
    Haml::Engine.new(file).def_method(obj, :render)
    result = RubyProf.profile { times.times { obj.render } }

    RubyProf.const_get("#{(ENV['OUTPUT'] || 'Flat').capitalize}Printer").new(result).print 
  end
rescue LoadError; end

# ----- Testing Multiple Rails Versions -----

rails_versions = [
  "v2.3.5",
  "v2.2.3",
  "v2.1.2",
]
rails_versions << "v2.0.5" if RUBY_VERSION =~ /^1\.8/

def test_rails_version(version)
  Dir.chdir "test/rails" do
    sh %{git checkout #{version}}
  end
  puts "Testing Rails #{version}"
  Rake::Task['test'].reenable
  Rake::Task['test'].execute
end

namespace :test do
  desc "Test all supported versions of rails. This takes a while."
  task :rails_compatibility do
    sh %{rm -rf test/rails}
    puts "Checking out rails. Please wait."
    sh %{git clone git://github.com/rails/rails.git test/rails}
    begin
      rails_versions.each {|version| test_rails_version version}

      puts "Checking out rails_xss. Please wait."
      sh %{git clone git://github.com/NZKoz/rails_xss.git test/plugins/rails_xss}
      test_rails_version(rails_versions.find {|s| s =~ /^v2\.3/})
    ensure
      `rm -rf test/rails`
      `rm -rf test/plugins`
    end
  end
end

# ----- Handling Updates -----

def email_on_error
  yield
rescue Exception => e
  IO.popen("sendmail nex342@gmail.com", "w") do |sm|
    sm << "From: nex3@nex-3.com\n" <<
      "To: nex342@gmail.com\n" <<
      "Subject: Exception when running rake #{Rake.application.top_level_tasks.join(', ')}\n" <<
      e.message << "\n\n" <<
      e.backtrace.join("\n")
  end
ensure
  raise e if e
end

def ensure_git_cleanup
  email_on_error {yield}
ensure
  sh %{git reset --hard HEAD}
  sh %{git clean -xdf}
  sh %{git checkout master}
end

task :handle_update do
  email_on_error do
    unless ENV["REF"] =~ %r{^refs/heads/(master|stable|haml-pages)$}
      puts "#{'=' * 20} Ignoring rake handle_update REF=#{ENV["REF"].inspect}"
      next
    end
    branch = $1

    puts
    puts
    puts '=' * 150
    puts "Running rake handle_update REF=#{ENV["REF"].inspect}"

    sh %{git fetch origin}
    sh %{git checkout stable}
    sh %{git reset --hard origin/stable}
    sh %{git checkout master}
    sh %{git reset --hard origin/master}

    case branch
    when "master"
      sh %{rake release_edge --trace}
    when "stable", "haml-pages"
      sh %{rake pages --trace}
    end

    puts 'Done running handle_update'
    puts '=' * 150
  end
end
