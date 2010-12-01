# vim: ts=2:sw=2:sts=2:et:fdm=marker
require 'tmpdir'
require 'socket'
require 'fileutils'
require 'rbconfig'
require 'thread'
require 'yaml'

class Object
  def systemu(*a, &b) SystemUniversal.new(*a, &b).systemu end
end

class SystemUniversal
#
# constants
#
  SystemUniversal::VERSION = '1.2.0' unless defined?  SystemUniversal::VERSION
  def version() SystemUniversal::VERSION end
#
# class methods
#

  @host = Socket.gethostname
  @ppid = Process.ppid
  @pid = Process.pid
  @turd = ENV['SYSTEMU_TURD']

  c = ::Config::CONFIG
  ruby = File.join(c['bindir'], c['ruby_install_name']) << c['EXEEXT']
  @ruby = if system('%s -e 42' % ruby)
    ruby
  else
    system('%s -e 42' % 'ruby') ? 'ruby' : warn('no ruby in PATH/CONFIG')
  end

  class << self
    %w( host ppid pid ruby turd ).each{|a| attr_accessor a}
  end

#
# instance methods
#

  def initialize argv, opts = {}, &block
    getopt = getopts opts

    @argv = argv
    @block = block

    @stdin = getopt[ ['stdin', 'in', '0', 0] ]
    @stdout = getopt[ ['stdout', 'out', '1', 1] ]
    @stderr = getopt[ ['stderr', 'err', '2', 2] ]
    @env = getopt[ 'env' ]
    @cwd = getopt[ 'cwd' ]

    @host = getopt[ 'host', self.class.host ]
    @ppid = getopt[ 'ppid', self.class.ppid ]
    @pid = getopt[ 'pid', self.class.pid ]
    @ruby = getopt[ 'ruby', self.class.ruby ]
  end

  def systemu
    tmpdir do |tmp|
      c = child_setup tmp
      status = nil

      begin
        thread = nil

        quietly{
          IO.popen "#{ @ruby } #{ c['program'] }", 'r+' do |pipe|
            line = pipe.gets
            case line
              when %r/^pid: \d+$/
                cid = Integer line[%r/\d+/] 
              else
                begin
                  buf = pipe.read
                  buf = "#{ line }#{ buf }"
                  e = Marshal.load buf
                  raise unless Exception === e
                  raise e
                rescue
                  raise "wtf?\n#{ buf }\n"
                end
            end
            thread = new_thread cid, @block if @block
            pipe.read rescue nil
          end
        }
        status = $?
      ensure
        if thread
          begin
            class << status
              attr 'thread'
            end
            status.instance_eval{ @thread = thread }
          rescue
            42
          end
        end
      end

      if @stdout or @stderr
        open(c['stdout']){|f| relay f => @stdout} if @stdout
        open(c['stderr']){|f| relay f => @stderr} if @stderr
        status
      else
        [status, IO.read(c['stdout']), IO.read(c['stderr'])]
      end
    end
  end

  def new_thread cid, block 
    q = Queue.new
    Thread.new(cid) do |cid| 
      current = Thread.current 
      current.abort_on_exception = true
      q.push current 
      block.call cid
    end
    q.pop
  end

  def child_setup tmp
    stdin = File.expand_path(File.join(tmp, 'stdin'))
    stdout = File.expand_path(File.join(tmp, 'stdout'))
    stderr = File.expand_path(File.join(tmp, 'stderr'))
    program = File.expand_path(File.join(tmp, 'program'))
    config = File.expand_path(File.join(tmp, 'config'))

    if @stdin
      open(stdin, 'w'){|f| relay @stdin => f}
    else
      FileUtils.touch stdin
    end
    FileUtils.touch stdout
    FileUtils.touch stderr

    c = {}
    c['argv'] = @argv
    c['env'] = @env
    c['cwd'] = @cwd
    c['stdin'] = stdin 
    c['stdout'] = stdout 
    c['stderr'] = stderr 
    c['program'] = program 
    open(config, 'w'){|f| YAML.dump c, f}

    open(program, 'w'){|f| f.write child_program(config)}

    c
  end

  def quietly
    v = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = v
  end

  def child_program config
    <<-program
      PIPE = STDOUT.dup
      begin
        require 'yaml'

        config = YAML.load(IO.read('#{ config }'))

        argv = config['argv']
        env = config['env']
        cwd = config['cwd']
        stdin = config['stdin']
        stdout = config['stdout']
        stderr = config['stderr']

        Dir.chdir cwd if cwd
        env.each{|k,v| ENV[k.to_s] = v.to_s} if env

        STDIN.reopen stdin
        STDOUT.reopen stdout
        STDERR.reopen stderr

        PIPE.puts "pid: \#{ Process.pid }"
        PIPE.flush                        ### the process is ready yo! 
        PIPE.close

        exec *argv
      rescue Exception => e
        PIPE.write Marshal.dump(e) rescue nil
        exit 42
      end
    program
  end

  def relay srcdst
    src, dst, ignored = srcdst.to_a.first
    if src.respond_to? 'read'
      while((buf = src.read(8192))); dst << buf; end
    else
      src.each{|buf| dst << buf}
    end
  end

  def tmpdir d = Dir.tmpdir, max = 42, &b
    i = -1 and loop{
      i += 1

      tmp = File.join d, "systemu_#{ @host }_#{ @ppid }_#{ @pid }_#{ rand }_#{ i += 1 }"

      begin
        Dir.mkdir tmp 
      rescue Errno::EEXIST
        raise if i >= max 
        next
      end

      break(
        if b
          begin
            b.call tmp
          ensure
            FileUtils.rm_rf tmp unless SystemU.turd 
          end
        else
          tmp
        end
      )
    }
  end

  def getopts opts = {}
    lambda do |*args|
      keys, default, ignored = args
      catch('opt') do
        [keys].flatten.each do |key|
          [key, key.to_s, key.to_s.intern].each do |key|
            throw 'opt', opts[key] if opts.has_key?(key)
          end
        end
        default
      end
    end
  end
end

SystemU = SystemUniversal unless defined? SystemU













if $0 == __FILE__
#
# date
#
  date = %q( ruby -e"  t = Time.now; STDOUT.puts t; STDERR.puts t  " )

  status, stdout, stderr = systemu date
  p [status, stdout, stderr]

  status = systemu date, 1=>(stdout = '')
  p [status, stdout]

  status = systemu date, 2=>(stderr = '')
  p [status, stderr]
#
# sleep
#
  sleep = %q( ruby -e"  p(sleep(1))  " )
  status, stdout, stderr = systemu sleep 
  p [status, stdout, stderr]

  sleep = %q( ruby -e"  p(sleep(42))  " )
  status, stdout, stderr = systemu(sleep){|cid| Process.kill 9, cid}
  p [status, stdout, stderr]
#
# env 
#
  env = %q( ruby -e"  p ENV['A']  " )
  status, stdout, stderr = systemu env, :env => {'A' => 42} 
  p [status, stdout, stderr]
#
# cwd 
#
  env = %q( ruby -e"  p Dir.pwd  " )
  status, stdout, stderr = systemu env, :cwd => Dir.tmpdir
  p [status, stdout, stderr]
end
