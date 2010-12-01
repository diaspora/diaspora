require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'right_http_connection')

AUTHOR = 'RightScale'  # can also be an array of Authors
EMAIL = "rubygems@rightscale.com"
DESCRIPTION = "RightScale's robust HTTP/S connection module"
GEM_NAME = 'right_http_connection' # what ppl will type to install your gem
RUBYFORGE_PROJECT = 'rightscale' # The unix name for your project
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
DOWNLOAD_PATH = "http://rubyforge.org/projects/#{RUBYFORGE_PROJECT}"

NAME = "right_http_connection"
REV = nil # UNCOMMENT IF REQUIRED: File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = RightHttpConnection::VERSION::STRING + (REV ? ".#{REV}" : "")
CLEAN.include ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']
RDOC_OPTS = ['--quiet', '--title', 'right_http_connection documentation',
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

# Suppress Hoe's self-inclusion as a dependency for our Gem. This also keeps
# Rake & rubyforge out of the dependency list. Users must manually install
# these gems to run tests, etc.
# TRB 2/19/09: also do this for the extra_dev_deps array present in newer hoes.
# Older versions of RubyGems will try to install developer-dependencies as
# required runtime dependencies....
class Hoe
  def extra_deps
    @extra_deps.reject do |x|
      Array(x).first == 'hoe'
    end
  end
  def extra_dev_deps
    @extra_dev_deps.reject do |x|
      Array(x).first == 'hoe'
    end
  end
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/test_*.rb"]
  p.clean_globs = CLEAN  #An array of file patterns to delete on clean.
  p.remote_rdoc_dir = "right_http_gem_doc"
  
  # == Optional
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  #p.extra_deps = []     # An array of rubygem dependencies [name, version], e.g. [ ['active_support', '>= 1.3.1'] ]
  #p.spec_extras = {}    # A hash of extra values to set in the gemspec.
end


desc 'Generate website files'
task :website_generate do
  Dir['website/**/*.txt'].each do |txt|
    sh %{ ruby scripts/txt2html #{txt} > #{txt.gsub(/txt$/,'html')} }
  end
end

desc 'Upload website files to rubyforge'
task :website_upload do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/"
  # remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/#{GEM_NAME}"
  local_dir = 'website'
  sh %{rsync -av #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload]

desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end
