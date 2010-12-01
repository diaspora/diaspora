This.author = "Ara T. Howard"
This.email = "ara.t.howard@gmail.com"
This.homepage = "http://github.com/ahoward/#{ This.lib }/tree/master"
This.rubyforge_project = 'codeforpeople'

task :default do
  puts(Rake::Task.tasks.map{|task| task.name} - ['default'])
end

task :spec do
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/*_spec.rb']
  end
end

task :gemspec do
  ignore_extensions = 'git', 'svn', 'tmp', /sw./, 'bak', 'gem'
  ignore_directories = 'pkg'
  ignore_files = 'test/log'

  shiteless = 
    lambda do |list|
      list.delete_if do |entry|
        next unless test(?e, entry)
        extension = File.basename(entry).split(%r/[.]/).last
        ignore_extensions.any?{|ext| ext === extension}
      end
      list.delete_if do |entry|
        next unless test(?d, entry)
        dirname = File.expand_path(entry)
        ignore_directories.any?{|dir| File.expand_path(dir) == dirname}
      end
      list.delete_if do |entry|
        next unless test(?f, entry)
        filename = File.expand_path(entry)
        ignore_files.any?{|file| File.expand_path(file) == filename}
      end
    end

  lib         = This.lib
  version     = This.version
  files       = shiteless[Dir::glob("**/**")]
  executables = shiteless[Dir::glob("bin/*")].map{|exe| File.basename(exe)}
  has_rdoc    = true #File.exist?('doc')
  test_files  = "test/#{ lib }.rb" if File.file?("test/#{ lib }.rb")

  extensions = This.extensions
  if extensions.nil?
    %w( Makefile configure extconf.rb ).each do |ext|
      extensions << ext if File.exists?(ext)
    end
  end
  extensions = [extensions].flatten.compact

  template = 
    if test(?e, 'gemspec.erb')
      Template{ IO.read('gemspec.erb') }
    else
      Template {
        <<-__
          ## #{ lib }.gemspec
          #

          Gem::Specification::new do |spec|
            spec.name = #{ lib.inspect }
            spec.version = #{ version.inspect }
            spec.platform = Gem::Platform::RUBY
            spec.summary = #{ lib.inspect }

            spec.files = #{ files.inspect }
            spec.executables = #{ executables.inspect }
            
            <% if test(?d, 'lib') %>
            spec.require_path = "lib"
            <% end %>

            spec.has_rdoc = #{ has_rdoc.inspect }
            spec.test_files = #{ test_files.inspect }
            #spec.add_dependency 'lib', '>= version'
            #spec.add_dependency 'fattr'

            spec.extensions.push(*#{ extensions.inspect })

            spec.rubyforge_project = #{ This.rubyforge_project.inspect }
            spec.author = #{ This.author.inspect }
            spec.email = #{ This.email.inspect }
            spec.homepage = #{ This.homepage.inspect }
          end
        __
      }
    end

  open("#{ lib }.gemspec", "w"){|fd| fd.puts template}
  This.gemspec = "#{ lib }.gemspec"
end

task :gem => [:clean, :gemspec] do
  Fu.mkdir_p This.pkgdir
  before = Dir['*.gem']
  cmd = "gem build #{ This.gemspec }"
  `#{ cmd }`
  after = Dir['*.gem']
  gem = ((after - before).first || after.first) or abort('no gem!')
  Fu.mv gem, This.pkgdir
  This.gem = File.basename(gem)
end

task :readme do
  samples = ''
  prompt = '~ > '
  lib = This.lib
  version = This.version

  Dir['sample*/*'].sort.each do |sample|
    samples << "\n" << "  <========< #{ sample } >========>" << "\n\n"

    cmd = "cat #{ sample }"
    samples << Util.indent(prompt + cmd, 2) << "\n\n"
    samples << Util.indent(`#{ cmd }`, 4) << "\n"

    cmd = "ruby #{ sample }"
    samples << Util.indent(prompt + cmd, 2) << "\n\n"

    cmd = "ruby -e'STDOUT.sync=true; exec %(ruby -Ilib -Iconfig #{ sample })'"
    samples << Util.indent(`#{ cmd } 2>&1`, 4) << "\n"
  end

  template = 
    if test(?e, 'readme.erb')
      Template{ IO.read('readme.erb') }
    else
      Template {
        <<-__
          NAME
            #{ lib }

          DESCRIPTION

          INSTALL
            gem install #{ lib }

          SAMPLES
            #{ samples }
        __
      }
    end

  open("README", "w"){|fd| fd.puts template}
end


task :clean do
  Dir[File.join(This.pkgdir, '**/**')].each{|entry| Fu.rm_rf(entry)}
end


task :release => [:clean, :gemspec, :gem] do
  gems = Dir[File.join(This.pkgdir, '*.gem')].flatten
  raise "which one? : #{ gems.inspect }" if gems.size > 1
  raise "no gems?" if gems.size < 1
  cmd = "rubyforge login && rubyforge add_release #{ This.rubyforge_project } #{ This.lib } #{ This.version } #{ This.pkgdir }/#{ This.gem }"
  puts cmd
  system cmd
end





BEGIN {
  $VERBOSE = nil

  require 'ostruct'
  require 'erb'
  require 'fileutils'

  Fu = FileUtils

  This = OpenStruct.new

  This.file = File.expand_path(__FILE__)
  This.dir = File.dirname(This.file)
  This.pkgdir = File.join(This.dir, 'pkg')

  lib = ENV['LIB']
  unless lib
    lib = File.basename(Dir.pwd)
  end
  This.lib = lib

  version = ENV['VERSION']
  unless version
    name = lib.capitalize
    library = "./lib/#{ lib }.rb"
    program = "./bin/#{ lib }"
    if test(?e, library)
      require library
      version = eval(name).send(:version)
    elsif test(?e, program)
      version = `#{ program } --version`.strip
    end
    abort('no version') if(version.nil? or version.empty?)
  end
  This.version = version

  abort('no lib') unless This.lib
  abort('no version') unless This.version

  module Util
    def indent(s, n = 2)
      s = unindent(s)
      ws = ' ' * n
      s.gsub(%r/^/, ws)
    end

    def unindent(s)
      indent = nil
      s.each do |line|
      next if line =~ %r/^\s*$/
      indent = line[%r/^\s*/] and break
    end
    indent ? s.gsub(%r/^#{ indent }/, "") : s
  end
    extend self
  end

  class Template
    def initialize(&block)
      @block = block
      @template = block.call.to_s
    end
    def expand(b=nil)
      ERB.new(Util.unindent(@template)).result(b||@block)
    end
    alias_method 'to_s', 'expand'
  end
  def Template(*args, &block) Template.new(*args, &block) end

  Dir.chdir(This.dir)
}
