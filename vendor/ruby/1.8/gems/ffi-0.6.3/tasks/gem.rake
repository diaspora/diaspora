
require 'find'
require 'rake/packagetask'
require 'rubygems/user_interaction'
require 'rubygems/builder'

module Bones
class GemPackageTask < Rake::PackageTask
  # Ruby GEM spec containing the metadata for this package.  The
  # name, version and package_files are automatically determined
  # from the GEM spec and don't need to be explicitly provided.
  #
  attr_accessor :gem_spec

  # Tasks from the Bones gem directory
  attr_reader :bones_files

  # Create a GEM Package task library.  Automatically define the gem
  # if a block is given.  If no block is supplied, then +define+
  # needs to be called to define the task.
  #
  def initialize(gem_spec)
    init(gem_spec)
    yield self if block_given?
    define if block_given?
  end

  # Initialization tasks without the "yield self" or define
  # operations.
  #
  def init(gem)
    super(gem.name, gem.version)
    @gem_spec = gem
    @package_files += gem_spec.files if gem_spec.files
    @bones_files = []

    local_setup = File.join(Dir.pwd, %w[tasks setup.rb])
    if !test(?e, local_setup)
      Dir.glob(::Bones.path(%w[lib bones tasks *])).each {|fn| bones_files << fn}
    end
  end

  # Create the Rake tasks and actions specified by this
  # GemPackageTask.  (+define+ is automatically called if a block is
  # given to +new+).
  #
  def define
    super
    task :prereqs
    task :package => ['gem:prereqs', "#{package_dir_path}/#{gem_file}"]
    file "#{package_dir_path}/#{gem_file}" => [package_dir_path] + package_files + bones_files do
      when_writing("Creating GEM") {
        chdir(package_dir_path) do
          Gem::Builder.new(gem_spec).build
          verbose(true) {
            mv gem_file, "../#{gem_file}"
          }
        end
      }
    end

    file package_dir_path => bones_files do
      mkdir_p package_dir rescue nil

      gem_spec.files = (gem_spec.files +
          bones_files.map {|fn| File.join('tasks', File.basename(fn))}).sort

      bones_files.each do |fn|
        base_fn = File.join('tasks', File.basename(fn))
        f = File.join(package_dir_path, base_fn)
        fdir = File.dirname(f)
        mkdir_p(fdir) if !File.exist?(fdir)
        if File.directory?(fn)
          mkdir_p(f)
        else
          raise "file name conflict for '#{base_fn}' (conflicts with '#{fn}')" if test(?e, f)
          safe_ln(fn, f)
        end
      end
    end
  end
  
  def gem_file
    if @gem_spec.platform == Gem::Platform::RUBY
      "#{package_name}.gem"
    else
      "#{package_name}-#{@gem_spec.platform}.gem"
    end
  end
end  # class GemPackageTask
end  # module Bones

namespace :gem do

  PROJ.gem._spec = Gem::Specification.new do |s|
    s.name = PROJ.name
    s.version = PROJ.version
    s.summary = PROJ.summary
    s.authors = Array(PROJ.authors)
    s.email = PROJ.email
    s.homepage = Array(PROJ.url).first
    s.rubyforge_project = PROJ.rubyforge.name

    s.description = PROJ.description

    PROJ.gem.dependencies.each do |dep|
      s.add_dependency(*dep)
    end

    PROJ.gem.development_dependencies.each do |dep|
      s.add_development_dependency(*dep)
    end

    s.files = PROJ.gem.files
    s.executables = PROJ.gem.executables.map {|fn| File.basename(fn)}
    s.extensions = PROJ.gem.files.grep %r/extconf\.rb$/

    s.bindir = 'bin'
    dirs = Dir["{#{PROJ.libs.join(',')}}"]
    s.require_paths = dirs unless dirs.empty?

    incl = Regexp.new(PROJ.rdoc.include.join('|'))
    excl = PROJ.rdoc.exclude.dup.concat %w[\.rb$ ^(\.\/|\/)?ext]
    excl = Regexp.new(excl.join('|'))
    rdoc_files = PROJ.gem.files.find_all do |fn|
                   case fn
                   when excl; false
                   when incl; true
                   else false end
                 end
    s.rdoc_options = PROJ.rdoc.opts + ['--main', PROJ.rdoc.main]
    s.extra_rdoc_files = rdoc_files
    s.has_rdoc = true

    if test ?f, PROJ.test.file
      s.test_file = PROJ.test.file
    else
      s.test_files = PROJ.test.files.to_a
    end

    # Do any extra stuff the user wants
    PROJ.gem.extras.each do |msg, val|
      case val
      when Proc
        val.call(s.send(msg))
      else
        s.send "#{msg}=", val
      end
    end
  end  # Gem::Specification.new

  Bones::GemPackageTask.new(PROJ.gem._spec) do |pkg|
    pkg.need_tar = PROJ.gem.need_tar
    pkg.need_zip = PROJ.gem.need_zip
  end

  desc 'Show information about the gem'
  task :debug => 'gem:prereqs' do
    puts PROJ.gem._spec.to_ruby
  end

  desc 'Write the gemspec '
  task :spec => 'gem:prereqs' do
    File.open("#{PROJ.name}.gemspec", 'w') do |f|
      f.write PROJ.gem._spec.to_ruby
    end
  end

  desc 'Install the gem'
  task :install => [:clobber, 'gem:package'] do
    sh "#{SUDO} #{GEM} install --local pkg/#{PROJ.gem._spec.full_name}"

    # use this version of the command for rubygems > 1.0.0
    #sh "#{SUDO} #{GEM} install --no-update-sources pkg/#{PROJ.gem._spec.full_name}"
  end

  desc 'Uninstall the gem'
  task :uninstall do
    installed_list = Gem.source_index.find_name(PROJ.name)
    if installed_list and installed_list.collect { |s| s.version.to_s}.include?(PROJ.version) then
      sh "#{SUDO} #{GEM} uninstall --version '#{PROJ.version}' --ignore-dependencies --executables #{PROJ.name}"
    end
  end

  desc 'Reinstall the gem'
  task :reinstall => [:uninstall, :install]

  desc 'Cleanup the gem'
  task :cleanup do
    sh "#{SUDO} #{GEM} cleanup #{PROJ.gem._spec.name}"
  end
end  # namespace :gem

desc 'Alias to gem:package'
task :gem => 'gem:package'

task :clobber => 'gem:clobber_package'
remove_desc_for_task 'gem:clobber_package'

# EOF
