require 'rake/clean'
require 'rake/testtask'
require 'fileutils'
require 'date'

task :default => :test
task :spec => :test

CLEAN.include "**/*.rbc"

def source_version
  @source_version ||= begin
    line = File.read('lib/sinatra/base.rb')[/^\s*VERSION = .*/]
    line.match(/.*VERSION = '(.*)'/)[1]
  end
end

def prev_feature
  source_version.gsub(/^(\d\.)(\d+)\..*$/) { $1 + ($2.to_i - 1).to_s }
end

def prev_version
  return prev_feature + '.0' if source_version.end_with? '.0'
  source_version.gsub(/\d+$/) { |s| s.to_i - 1 }
end

# SPECS ===============================================================

task :test do
  ENV['LANG'] = 'C'
  ENV.delete 'LC_CTYPE'
end

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
  t.ruby_opts << '-I.'
end

# Rcov ================================================================

namespace :test do
  desc 'Mesures test coverage'
  task :coverage do
    rm_f "coverage"
    sh "rcov -Ilib test/*_test.rb"
  end
end

# Website =============================================================

desc 'Generate RDoc under doc/api'
task 'doc'     => ['doc:api']
task('doc:api') { sh "yardoc -o doc/api" }
CLEAN.include 'doc/api'

# README ===============================================================

task :add_template, [:name] do |t, args|
  Dir.glob('README.*') do |file|
    code = File.read(file)
    if code =~ /^===.*#{args.name.capitalize}/
      puts "Already covered in #{file}"
    else
      template = code[/===[^\n]*Liquid.*index\.liquid<\/tt>[^\n]*/m]
      if !template
        puts "Liquid not found in #{file}"
      else
        puts "Adding section to #{file}"
        template = template.gsub(/Liquid/, args.name.capitalize).gsub(/liquid/, args.name.downcase)        
        code.gsub! /^(\s*===.*CoffeeScript)/, "\n" << template << "\n\\1"
        File.open(file, "w") { |f| f << code }
      end
    end
  end
end

# Thanks in announcement ===============================================

team = ["Ryan Tomayko", "Blake Mizerany", "Simon Rozet", "Konstantin Haase"]
desc "list of contributors"
task :thanks, [:release,:backports] do |t, a|
  a.with_defaults :release => "#{prev_version}..HEAD",
    :backports => "#{prev_feature}.0..#{prev_feature}.x"
  included = `git log --format=format:"%aN\t%s" #{a.release}`.lines.to_a
  excluded = `git log --format=format:"%aN\t%s" #{a.backports}`.lines.to_a
  commits  = (included - excluded).group_by { |c| c[/^[^\t]+/] }
  authors  = commits.keys.sort_by { |n| - commits[n].size } - team
  puts authors[0..-2].join(', ') << " and " << authors.last,
    "(based on commits included in #{a.release}, but not in #{a.backports})"
end

task :authors, [:format, :sep] do |t, a|
  a.with_defaults :format => "%s (%d)", :sep => ', '
  authors = Hash.new { |h,k| h[k] = 0 }
  blake   = "Blake Mizerany"
  mapping = {
    "blake.mizerany@gmail.com" => blake, "bmizerany" => blake,
    "a_user@mac.com" => blake, "ichverstehe" => "Harry Vangberg",
    "Wu Jiang (nouse)" => "Wu Jiang" }
  `git shortlog -s`.lines.map do |line|
    num, name = line.split("\t", 2).map(&:strip)
    authors[mapping[name] || name] += num.to_i
  end
  puts authors.sort_by { |n,c| -c }.map { |e| a.format % e }.join(a.sep)
end

# PACKAGING ============================================================

if defined?(Gem)
  # Load the gemspec using the same limitations as github
  def spec
    require 'rubygems' unless defined? Gem::Specification
    @spec ||= eval(File.read('sinatra.gemspec'))
  end

  def package(ext='')
    "pkg/sinatra-#{spec.version}" + ext
  end

  desc 'Build packages'
  task :package => %w[.gem .tar.gz].map {|e| package(e)}

  desc 'Build and install as local gem'
  task :install => package('.gem') do
    sh "gem install #{package('.gem')}"
  end

  directory 'pkg/'
  CLOBBER.include('pkg')

  file package('.gem') => %w[pkg/ sinatra.gemspec] + spec.files do |f|
    sh "gem build sinatra.gemspec"
    mv File.basename(f.name), f.name
  end

  file package('.tar.gz') => %w[pkg/] + spec.files do |f|
    sh <<-SH
      git archive \
        --prefix=sinatra-#{source_version}/ \
        --format=tar \
        HEAD | gzip > #{f.name}
    SH
  end

  task 'sinatra.gemspec' => FileList['{lib,test,compat}/**','Rakefile','CHANGES','*.rdoc'] do |f|
    # read spec file and split out manifest section
    spec = File.read(f.name)
    head, manifest, tail = spec.split("  # = MANIFEST =\n")
    # replace version and date
    head.sub!(/\.version = '.*'/, ".version = '#{source_version}'")
    head.sub!(/\.date = '.*'/, ".date = '#{Date.today.to_s}'")
    # determine file list from git ls-files
    files = `git ls-files`.
      split("\n").
      sort.
      reject{ |file| file =~ /^\./ }.
      reject { |file| file =~ /^doc/ }.
      map{ |file| "    #{file}" }.
      join("\n")
    # piece file back together and write...
    manifest = "  s.files = %w[\n#{files}\n  ]\n"
    spec = [head,manifest,tail].join("  # = MANIFEST =\n")
    File.open(f.name, 'w') { |io| io.write(spec) }
    puts "updated #{f.name}"
  end

  task 'release' => ['test', package('.gem')] do
    sh <<-SH
      gem install #{package('.gem')} --local &&
      gem push #{package('.gem')}  &&
      git commit --allow-empty -a -m '#{source_version} release'  &&
      git tag -s v#{source_version} -m '#{source_version} release'  &&
      git tag -s #{source_version} -m '#{source_version} release'  &&
      git push && (git push sinatra || true) &&
      git push --tags && (git push sinatra --tags || true)
    SH
  end
end
