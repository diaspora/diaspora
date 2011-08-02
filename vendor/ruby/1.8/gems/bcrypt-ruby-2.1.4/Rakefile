require 'rspec/core/rake_task'
require 'rake/gempackagetask'
require 'rake/extensiontask'
require 'rake/javaextensiontask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/clean'
require 'rake/rdoctask'
require 'benchmark'

CLEAN.include(
  "ext/mri/*.o",
  "ext/mri/*.bundle",
  "ext/mri/*.so",
  "ext/jruby/bcrypt_jruby/*.class"
)
CLOBBER.include(
  "ext/mri/Makefile",
  "doc/coverage",
  "pkg"
)
GEMSPEC = eval(File.read(File.expand_path("../bcrypt-ruby.gemspec", __FILE__)))

task :default => [:compile, :spec]

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run all specs, with coverage testing"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_path = 'doc/coverage'
  t.rcov_opts = ['--exclude', 'rspec,diff-lcs,rcov,_spec,_helper']
end

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options += GEMSPEC.rdoc_options
  rdoc.template = ENV['TEMPLATE'] if ENV['TEMPLATE']
  rdoc.rdoc_files.include(*GEMSPEC.extra_rdoc_files)
end

Rake::GemPackageTask.new(GEMSPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

if RUBY_PLATFORM =~ /java/
  Rake::JavaExtensionTask.new('bcrypt_ext', GEMSPEC) do |ext|
    ext.ext_dir = 'ext/jruby'
  end
else
  Rake::ExtensionTask.new("bcrypt_ext", GEMSPEC) do |ext|
    ext.ext_dir = 'ext/mri'
    ext.cross_compile = true
    ext.cross_platform = ['x86-mingw32', 'x86-mswin32-60']

    # inject 1.8/1.9 pure-ruby entry point
    ext.cross_compiling do |spec|
      spec.files += ["lib/#{ext.name}.rb"]
    end
  end
end

# Entry point for fat-binary gems on win32
file("lib/bcrypt_ext.rb") do |t|
  File.open(t.name, 'wb') do |f|
    f.write <<-eoruby
RUBY_VERSION =~ /(\\d+.\\d+)/
require "\#{$1}/#{File.basename(t.name, '.rb')}"
    eoruby
  end
  at_exit{ FileUtils.rm t.name if File.exists?(t.name) }
end

desc "Run a set of benchmarks on the compiled extension."
task :benchmark do
  TESTS = 100
  TEST_PWD = "this is a test"
  require File.expand_path(File.join(File.dirname(__FILE__), "lib", "bcrypt"))
  Benchmark.bmbm do |results|
    4.upto(10) do |n|
      results.report("cost #{n}:") { TESTS.times { BCrypt::Password.create(TEST_PWD, :cost => n) } }
    end
  end
end
