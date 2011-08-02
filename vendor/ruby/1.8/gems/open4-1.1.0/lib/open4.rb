# vim: ts=2:sw=2:sts=2:et:fdm=marker
require 'fcntl'
require 'timeout'
require 'thread'

module Open4
  VERSION = '1.1.0'
  def self.version() VERSION end

  class Error < ::StandardError; end

  def popen4(*cmd, &b)
    pw, pr, pe, ps = IO.pipe, IO.pipe, IO.pipe, IO.pipe

    verbose = $VERBOSE
    begin
      $VERBOSE = nil
      ps.first.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
      ps.last.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)

      cid = fork {
        pw.last.close
        STDIN.reopen pw.first
        pw.first.close

        pr.first.close
        STDOUT.reopen pr.last
        pr.last.close

        pe.first.close
        STDERR.reopen pe.last
        pe.last.close

        STDOUT.sync = STDERR.sync = true

        begin
          exec(*cmd)
          raise 'forty-two' 
        rescue Exception => e
          Marshal.dump(e, ps.last)
          ps.last.flush
        end
        ps.last.close unless (ps.last.closed?)
        exit!
      }
    ensure
      $VERBOSE = verbose
    end

    [pw.first, pr.last, pe.last, ps.last].each{|fd| fd.close}

    begin
      e = Marshal.load ps.first
      raise(Exception === e ? e : "unknown failure!")
    rescue EOFError # If we get an EOF error, then the exec was successful
      42
    ensure
      ps.first.close
    end

    pw.last.sync = true

    pi = [pw.last, pr.first, pe.first]

    if b 
      begin
        b[cid, *pi]
        Process.waitpid2(cid).last
      ensure
        pi.each{|fd| fd.close unless fd.closed?}
      end
    else
      [cid, pw.last, pr.first, pe.first]
    end
  end
  alias open4 popen4
  module_function :popen4
  module_function :open4

  class SpawnError < Error
    attr 'cmd'
    attr 'status'
    attr 'signals'
    def exitstatus
      @status.exitstatus
    end
    def initialize cmd, status
      @cmd, @status = cmd, status
      @signals = {} 
      if status.signaled?
        @signals['termsig'] = status.termsig
        @signals['stopsig'] = status.stopsig
      end
      sigs = @signals.map{|k,v| "#{ k }:#{ v.inspect }"}.join(' ')
      super "cmd <#{ cmd }> failed with status <#{ exitstatus.inspect }> signals <#{ sigs }>"
    end
  end

  class ThreadEnsemble
    attr 'threads'

    def initialize cid
      @cid, @threads, @argv, @done, @running = cid, [], [], Queue.new, false
      @killed = false
    end

    def add_thread *a, &b
      @running ? raise : (@argv << [a, b])
    end

#
# take down process more nicely
#
    def killall
      c = Thread.critical
      return nil if @killed
      Thread.critical = true
      (@threads - [Thread.current]).each{|t| t.kill rescue nil}
      @killed = true
    ensure
      Thread.critical = c
    end

    def run
      @running = true

      begin
        @argv.each do |a, b|
          @threads << Thread.new(*a) do |*a|
            begin
              b[*a]
            ensure
              killall rescue nil if $!
              @done.push Thread.current
            end
          end
        end
      rescue
        killall
        raise
      ensure
        all_done
      end

      @threads.map{|t| t.value}
    end

    def all_done
      @threads.size.times{ @done.pop }
    end
  end

  def to timeout = nil
    Timeout.timeout(timeout){ yield }
  end
  module_function :to

  def new_thread *a, &b
    cur = Thread.current
    Thread.new(*a) do |*a|
      begin
        b[*a]
      rescue Exception => e
        cur.raise e
      end
    end
  end
  module_function :new_thread

  def getopts opts = {}
    lambda do |*args|
      keys, default, ignored = args
      catch(:opt) do
        [keys].flatten.each do |key|
          [key, key.to_s, key.to_s.intern].each do |key|
            throw :opt, opts[key] if opts.has_key?(key)
          end
        end
        default
      end
    end
  end
  module_function :getopts

  def relay src, dst = nil, t = nil
    send_dst =
      if dst.respond_to?(:call)
        lambda{|buf| dst.call(buf)}
      elsif dst.respond_to?(:<<)
        lambda{|buf| dst << buf }
      else
        lambda{|buf| buf }
      end

    unless src.nil?
      if src.respond_to? :gets
        while buf = to(t){ src.gets }
          send_dst[buf]
        end

      elsif src.respond_to? :each
        q = Queue.new
        th = nil

        timer_set = lambda do |t|
          th = new_thread{ to(t){ q.pop } }
        end

        timer_cancel = lambda do |t|
          th.kill if th rescue nil
        end

        timer_set[t]
        begin
          src.each do |buf|
            timer_cancel[t]
            send_dst[buf]
            timer_set[t]
          end
        ensure
          timer_cancel[t]
        end

      elsif src.respond_to? :read
        buf = to(t){ src.read }
        send_dst[buf]

      else
        buf = to(t){ src.to_s }
        send_dst[buf]
      end
    end
  end
  module_function :relay

  def spawn arg, *argv 
    argv.unshift(arg)
    opts = ((argv.size > 1 and Hash === argv.last) ? argv.pop : {})
    argv.flatten!
    cmd = argv.join(' ')


    getopt = getopts opts

    ignore_exit_failure = getopt[ 'ignore_exit_failure', getopt['quiet', false] ]
    ignore_exec_failure = getopt[ 'ignore_exec_failure', !getopt['raise', true] ]
    exitstatus = getopt[ %w( exitstatus exit_status status ) ]
    stdin = getopt[ %w( stdin in i 0 ) << 0 ]
    stdout = getopt[ %w( stdout out o 1 ) << 1 ]
    stderr = getopt[ %w( stderr err e 2 ) << 2 ]
    pid = getopt[ 'pid' ]
    timeout = getopt[ %w( timeout spawn_timeout ) ]
    stdin_timeout = getopt[ %w( stdin_timeout ) ]
    stdout_timeout = getopt[ %w( stdout_timeout io_timeout ) ]
    stderr_timeout = getopt[ %w( stderr_timeout ) ]
    status = getopt[ %w( status ) ]
    cwd = getopt[ %w( cwd dir ) ]

    exitstatus =
      case exitstatus
        when TrueClass, FalseClass
          ignore_exit_failure = true if exitstatus
          [0]
        else
          [*(exitstatus || 0)].map{|i| Integer i}
      end

    stdin ||= '' if stdin_timeout
    stdout ||= '' if stdout_timeout
    stderr ||= '' if stderr_timeout

    started = false

    status =
      begin
        chdir(cwd) do
          Timeout::timeout(timeout) do
            popen4(*argv) do |c, i, o, e|
              started = true

              %w( replace pid= << push update ).each do |msg|
                break(pid.send(msg, c)) if pid.respond_to? msg 
              end

              te = ThreadEnsemble.new c

              te.add_thread(i, stdin) do |i, stdin|
                relay stdin, i, stdin_timeout
                i.close rescue nil
              end

              te.add_thread(o, stdout) do |o, stdout|
                relay o, stdout, stdout_timeout
              end

              te.add_thread(e, stderr) do |o, stderr|
                relay e, stderr, stderr_timeout
              end

              te.run
            end
          end
        end
      rescue
        raise unless(not started and ignore_exec_failure)
      end

    raise SpawnError.new(cmd, status) unless
      (ignore_exit_failure or (status.nil? and ignore_exec_failure) or exitstatus.include?(status.exitstatus))

    status
  end
  module_function :spawn

  def chdir cwd, &block
    return(block.call Dir.pwd) unless cwd
    Dir.chdir cwd, &block
  end
  module_function :chdir

  def background arg, *argv 
    require 'thread'
    q = Queue.new
    opts = { 'pid' => q, :pid => q }
    case argv.last
      when Hash
        argv.last.update opts
      else
        argv.push opts
    end
    thread = Thread.new(arg, argv){|arg, argv| spawn arg, *argv}
    sc = class << thread; self; end
    sc.module_eval {
      define_method(:pid){ @pid ||= q.pop }
      define_method(:spawn_status){ @spawn_status ||= value }
      define_method(:exitstatus){ @exitstatus ||= spawn_status.exitstatus }
    }
    thread
  end
  alias bg background
  module_function :background
  module_function :bg

  def maim pid, opts = {}
    getopt = getopts opts
    sigs = getopt[ 'signals', %w(SIGTERM SIGQUIT SIGKILL) ]
    suspend = getopt[ 'suspend', 4 ]
    pid = Integer pid
    existed = false
    sigs.each do |sig|
      begin
        Process.kill sig, pid
        existed = true 
      rescue Errno::ESRCH
        return(existed ? nil : true)
      end
      return true unless alive? pid
      sleep suspend
      return true unless alive? pid
    end
    return(not alive?(pid)) 
  end
  module_function :maim

  def alive pid
    pid = Integer pid
    begin
      Process.kill 0, pid
      true
    rescue Errno::ESRCH
      false
    end
  end
  alias alive? alive
  module_function :alive
  module_function :'alive?'
end

def open4(*cmd, &b) cmd.size == 0 ? Open4 : Open4::popen4(*cmd, &b) end
