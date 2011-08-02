This.rubyforge_project = 'codeforpeople'
This.author = "Ara T. Howard"
This.email = "ara.t.howard@gmail.com"
This.homepage = "http://github.com/ahoward/#{ This.lib }"


task :default do
  puts((Rake::Task.tasks.map{|task| task.name.gsub(/::/,':')} - ['default']).sort)
end

task :test do
  run_tests!
end

namespace :test do
  task(:unit){ run_tests!(:unit) }
  task(:functional){ run_tests!(:functional) }
  task(:integration){ run_tests!(:integration) }
end

def run_tests!(which = nil)
  which ||= '**'
  test_dir = File.join(This.dir, "test")
  test_glob ||= File.join(test_dir, "#{ which }/**_test.rb")
  test_rbs = Dir.glob(test_glob).sort
        
  div = ('=' * 119)
  line = ('-' * 119)
  helper = "-r ./test/helper.rb" if test(?e, "./test/helper.rb")

  test_rbs.each_with_index do |test_rb, index|
    testno = index + 1
    command = "#{ This.ruby } -I ./lib -I ./test/lib #{ helper } #{ test_rb }"

    puts
    say(div, :color => :cyan, :bold => true)
    say("@#{ testno } => ", :bold => true, :method => :print)
    say(command, :color => :cyan, :bold => true)
    say(line, :color => :cyan, :bold => true)

    system(command)

    say(line, :color => :cyan, :bold => true)

    status = $?.exitstatus

    if status.zero? 
      say("@#{ testno } <= ", :bold => true, :color => :white, :method => :print)
      say("SUCCESS", :color => :green, :bold => true)
    else
      say("@#{ testno } <= ", :bold => true, :color => :white, :method => :print)
      say("FAILURE", :color => :red, :bold => true)
    end
    say(line, :color => :cyan, :bold => true)

    exit(status) unless status.zero?
  end
end


task :gemspec do
  ignore_extensions = 'git', 'svn', 'tmp', /sw./, 'bak', 'gem'
  ignore_directories = %w[ pkg ]
  ignore_files = %w[ test/log ]

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
  object      = This.object
  version     = This.version
  files       = shiteless[Dir::glob("**/**")]
  executables = shiteless[Dir::glob("bin/*")].map{|exe| File.basename(exe)}
  has_rdoc    = true #File.exist?('doc')
  test_files  = "test/#{ lib }.rb" if File.file?("test/#{ lib }.rb")
  summary     = object.respond_to?(:summary) ? object.summary : "summary: #{ lib } kicks the ass"
  description = object.respond_to?(:description) ? object.description : "description: #{ lib } kicks the ass"

  if This.extensions.nil?
    This.extensions = []
    extensions = This.extensions
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
            spec.description = #{ description.inspect }

            spec.files = #{ files.inspect }
            spec.executables = #{ executables.inspect }
            
            spec.require_path = "lib"

            spec.has_rdoc = #{ has_rdoc.inspect }
            spec.test_files = #{ test_files.inspect }

          # spec.add_dependency 'lib', '>= version'

            spec.extensions.push(*#{ extensions.inspect })

            spec.rubyforge_project = #{ This.rubyforge_project.inspect }
            spec.author = #{ This.author.inspect }
            spec.email = #{ This.email.inspect }
            spec.homepage = #{ This.homepage.inspect }
          end
        __
      }
    end

  Fu.mkdir_p(This.pkgdir)
  This.gemspec = File.join(This.dir, "#{ This.lib }.gemspec") #File.join(This.pkgdir, "gemspec.rb")
  open("#{ This.gemspec }", "w"){|fd| fd.puts(template)}
end

task :gem => [:clean, :gemspec] do
  Fu.mkdir_p(This.pkgdir)
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

    cmd = "ruby -e'STDOUT.sync=true; exec %(ruby -I ./lib #{ sample })'"
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
  cmd = "gem push #{ This.pkgdir }/#{ This.gem }"
  puts cmd
  system cmd
end





BEGIN {
# support for this rakefile
#
  $VERBOSE = nil

  require 'ostruct'
  require 'erb'
  require 'fileutils'
  require 'rbconfig'

# fu shortcut
#
  Fu = FileUtils

# cache a bunch of stuff about this rakefile/environment
#
  This = OpenStruct.new

  This.file = File.expand_path(__FILE__)
  This.dir = File.dirname(This.file)
  This.pkgdir = File.join(This.dir, 'pkg')

# grok lib
#
  lib = ENV['LIB']
  unless lib
    lib = File.basename(Dir.pwd).sub(/[-].*$/, '')
  end
  This.lib = lib

# grok version
#
  version = ENV['VERSION']
  unless version
    require "./lib/#{ This.lib }"
    This.name = lib.capitalize
    This.object = eval(This.name)
    version = This.object.send(:version)
  end
  This.version = version

# we need to know the name of the lib an it's version
#
  abort('no lib') unless This.lib
  abort('no version') unless This.version

# discover full path to this ruby executable
#
  c = Config::CONFIG
  bindir = c["bindir"] || c['BINDIR']
  ruby_install_name = c['ruby_install_name'] || c['RUBY_INSTALL_NAME'] || 'ruby'
  ruby_ext = c['EXEEXT'] || ''
  ruby = File.join(bindir, (ruby_install_name + ruby_ext))
  This.ruby = ruby

# some utils
#
  module Util
    def indent(s, n = 2)
      s = unindent(s)
      ws = ' ' * n
      s.gsub(%r/^/, ws)
    end

    def unindent(s)
      indent = nil
      s.each_line do |line|
        next if line =~ %r/^\s*$/
        indent = line[%r/^\s*/] and break
      end
      indent ? s.gsub(%r/^#{ indent }/, "") : s
    end
    extend self
  end

# template support
#
  class Template
    def initialize(&block)
      @block = block.binding
      @template = block.call.to_s
    end
    def expand(b=nil)
      ERB.new(Util.unindent(@template)).result(b||@block)
    end
    alias_method 'to_s', 'expand'
  end
  def Template(*args, &block) Template.new(*args, &block) end

# colored console output support
#
  This.ansi = {
    :clear      => "\e[0m",
    :reset      => "\e[0m",
    :erase_line => "\e[K",
    :erase_char => "\e[P",
    :bold       => "\e[1m",
    :dark       => "\e[2m",
    :underline  => "\e[4m",
    :underscore => "\e[4m",
    :blink      => "\e[5m",
    :reverse    => "\e[7m",
    :concealed  => "\e[8m",
    :black      => "\e[30m",
    :red        => "\e[31m",
    :green      => "\e[32m",
    :yellow     => "\e[33m",
    :blue       => "\e[34m",
    :magenta    => "\e[35m",
    :cyan       => "\e[36m",
    :white      => "\e[37m",
    :on_black   => "\e[40m",
    :on_red     => "\e[41m",
    :on_green   => "\e[42m",
    :on_yellow  => "\e[43m",
    :on_blue    => "\e[44m",
    :on_magenta => "\e[45m",
    :on_cyan    => "\e[46m",
    :on_white   => "\e[47m"
  }
  def say(phrase, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options[:color] = args.shift.to_s.to_sym unless args.empty?
    keys = options.keys
    keys.each{|key| options[key.to_s.to_sym] = options.delete(key)}

    color = options[:color]
    bold = options.has_key?(:bold)

    parts = [phrase]
    parts.unshift(This.ansi[color]) if color
    parts.unshift(This.ansi[:bold]) if bold
    parts.push(This.ansi[:clear]) if parts.size > 1

    method = options[:method] || :puts

    Kernel.send(method, parts.join)
  end

# always run out of the project dir
#
  Dir.chdir(This.dir)
}
