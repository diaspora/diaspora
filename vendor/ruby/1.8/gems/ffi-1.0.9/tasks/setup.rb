
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'ostruct'
require 'find'

class OpenStruct; undef :gem; end

# TODO: make my own openstruct type object that includes descriptions
# TODO: use the descriptions to output help on the available bones options

PROJ = OpenStruct.new(
  # Project Defaults
  :name => nil,
  :summary => nil,
  :description => nil,
  :changes => nil,
  :authors => nil,
  :email => nil,
  :url => "\000",
  :version => ENV['VERSION'] || '0.0.0',
  :exclude => %w(tmp$ bak$ ~$ CVS \.svn/ \.git/ ^pkg/),
  :release_name => ENV['RELEASE'],

  # System Defaults
  :ruby_opts => %w(-w),
  :libs => [],
  :history_file => 'History.txt',
  :readme_file => 'README.txt',
  :ignore_file => '.bnsignore',

  # Announce
  :ann => OpenStruct.new(
    :file => 'announcement.txt',
    :text => nil,
    :paragraphs => [],
    :email => {
      :from     => nil,
      :to       => %w(ruby-talk@ruby-lang.org),
      :server   => 'localhost',
      :port     => 587,
      :domain   => ENV['HOSTNAME'],
      :acct     => nil,
      :passwd   => nil,
      :authtype => :plain
    }
  ),

  # Gem Packaging
  :gem => OpenStruct.new(
    :dependencies => [],
    :development_dependencies => [],
    :executables => nil,
    :extensions => FileList['ext/**/extconf.rb'],
    :files => nil,
    :need_tar => true,
    :need_zip => false,
    :extras => {}
  ),

  # File Annotations
  :notes => OpenStruct.new(
    :exclude => %w(^tasks/setup\.rb$),
    :extensions => %w(.txt .rb .erb .rdoc) << '',
    :tags => %w(FIXME OPTIMIZE TODO)
  ),

  # Rcov
  :rcov => OpenStruct.new(
    :dir => 'coverage',
    :opts => %w[--sort coverage -T],
    :threshold => 90.0,
    :threshold_exact => false
  ),

  # Rdoc
  :rdoc => OpenStruct.new(
    :opts => [],
    :include => %w(^lib/ ^bin/ ^ext/ \.txt$ \.rdoc$),
    :exclude => %w(extconf\.rb$),
    :main => nil,
    :dir => 'doc',
    :remote_dir => nil
  ),

  # Rubyforge
  :rubyforge => OpenStruct.new(
    :name => "\000"
  ),

  # Rspec
  :spec => OpenStruct.new(
    :files => FileList['spec/**/*_spec.rb'],
    :opts => []
  ),

  # Subversion Repository
  :svn => OpenStruct.new(
    :root => nil,
    :path => '',
    :trunk => 'trunk',
    :tags => 'tags',
    :branches => 'branches'
  ),

  # Test::Unit
  :test => OpenStruct.new(
    :files => FileList['test/**/test_*.rb'],
    :file  => 'test/all.rb',
    :opts  => []
  )
)

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
post_load_fn = File.join(tasks_dir, 'post_load.rake')
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
rakefiles.unshift(rakefiles.delete(post_load_fn)).compact!
import(*rakefiles)

# Setup the project libraries
%w(lib ext).each {|dir| PROJ.libs << dir if test ?d, dir}

# Setup some constants
WIN32 = %r/djgpp|(cyg|ms|bcc)win|mingw/ =~ RUBY_PLATFORM unless defined? WIN32

DEV_NULL = WIN32 ? 'NUL:' : '/dev/null'

def quiet( &block )
  io = [STDOUT.dup, STDERR.dup]
  STDOUT.reopen DEV_NULL
  STDERR.reopen DEV_NULL
  block.call
ensure
  STDOUT.reopen io.first
  STDERR.reopen io.last
  $stdout, $stderr = STDOUT, STDERR
end

DIFF = if WIN32 then 'diff.exe'
       else
         if quiet {system "gdiff", __FILE__, __FILE__} then 'gdiff'
         else 'diff' end
       end unless defined? DIFF

SUDO = if WIN32 then ''
       else
         if quiet {system 'which sudo'} then 'sudo'
         else '' end
       end

RCOV = WIN32 ? 'rcov.bat' : 'rcov'
RDOC = WIN32 ? 'rdoc.bat' : 'rdoc'
GEM  = WIN32 ? 'gem.bat'  : 'gem'

%w(rcov spec/rake/spectask rubyforge bones facets/ansicode).each do |lib|
  begin
    require lib
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", true}
  rescue LoadError
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", false}
  end
end
HAVE_SVN = (Dir.entries(Dir.pwd).include?('.svn') and
            system("svn --version 2>&1 > #{DEV_NULL}"))
HAVE_GIT = (Dir.entries(Dir.pwd).include?('.git') and
            system("git --version 2>&1 > #{DEV_NULL}"))

# Add bones as a development dependency
#
if HAVE_BONES
  bones_version = defined?(Bones::VERSION) ? Bones::VERSION : Bones.version
  PROJ.gem.development_dependencies << ['bones', ">= #{bones_version}"]
end

# Reads a file at +path+ and spits out an array of the +paragraphs+
# specified.
#
#    changes = paragraphs_of('History.txt', 0..1).join("\n\n")
#    summary, *description = paragraphs_of('README.txt', 3, 3..8)
#
def paragraphs_of( path, *paragraphs )
  title = String === paragraphs.first ? paragraphs.shift : nil
  ary = File.read(path).delete("\r").split(/\n\n+/)

  result = if title
    tmp, matching = [], false
    rgxp = %r/^=+\s*#{Regexp.escape(title)}/i
    paragraphs << (0..-1) if paragraphs.empty?

    ary.each do |val|
      if val =~ rgxp
        break if matching
        matching = true
        rgxp = %r/^=+/i
      elsif matching
        tmp << val
      end
    end
    tmp
  else ary end

  result.values_at(*paragraphs)
end

# Adds the given gem _name_ to the current project's dependency list. An
# optional gem _version_ can be given. If omitted, the newest gem version
# will be used.
#
def depend_on( name, version = nil )
  spec = Gem.source_index.find_name(name).last
  version = spec.version.to_s if version.nil? and !spec.nil?

  PROJ.gem.dependencies << case version
    when nil; [name]
    when %r/^\d/; [name, ">= #{version}"]
    else [name, version] end
end

# Adds the given arguments to the include path if they are not already there
#
def ensure_in_path( *args )
  args.each do |path|
    path = File.expand_path(path)
    $:.unshift(path) if test(?d, path) and not $:.include?(path)
  end
end

# Find a rake task using the task name and remove any description text. This
# will prevent the task from being displayed in the list of available tasks.
#
def remove_desc_for_task( names )
  Array(names).each do |task_name|
    task = Rake.application.tasks.find {|t| t.name == task_name}
    next if task.nil?
    task.instance_variable_set :@comment, nil
  end
end

# Change working directories to _dir_, call the _block_ of code, and then
# change back to the original working directory (the current directory when
# this method was called).
#
def in_directory( dir, &block )
  curdir = pwd
  begin
    cd dir
    return block.call
  ensure
    cd curdir
  end
end

# Scans the current working directory and creates a list of files that are
# candidates to be in the manifest.
#
def manifest
  files = []
  exclude = PROJ.exclude.dup
  comment = %r/^\s*#/
 
  # process the ignore file and add the items there to the exclude list
  if test(?f, PROJ.ignore_file)
    ary = []
    File.readlines(PROJ.ignore_file).each do |line|
      next if line =~ comment
      line.chomp!
      line.strip!
      next if line.nil? or line.empty?

      glob = line =~ %r/\*\./ ? File.join('**', line) : line
      Dir.glob(glob).each {|fn| ary << "^#{Regexp.escape(fn)}"}
    end
    exclude.concat ary
  end

  # generate a regular expression from the exclude list
  exclude = Regexp.new(exclude.join('|'))

  Find.find '.' do |path|
    path.sub! %r/^(\.\/|\/)/o, ''
    next unless test ?f, path
    next if path =~ exclude
    files << path
  end
  files.sort!
end

# We need a "valid" method thtat determines if a string is suitable for use
# in the gem specification.
#
class Object
  def valid?
    return !(self.empty? or self == "\000") if self.respond_to?(:to_str)
    return false
  end
end

# EOF
