require 'ruby_debug.so'
require 'rubygems'
require 'linecache'

module Debugger
  
  # Default options to Debugger.start
  DEFAULT_START_SETTINGS = { 
    :init        => true,  # Set $0 and save ARGV? 
    :post_mortem => false, # post-mortem debugging on uncaught exception?
    :tracing     => nil    # Debugger.tracing value. true/false resets,
                           # nil keeps the prior value
  } unless defined?(DEFAULT_START_SETTINGS)

  class Context
    def interrupt
      self.stop_next = 1
    end
    
    alias __c_frame_binding frame_binding
    def frame_binding(frame)
      __c_frame_binding(frame) || hbinding(frame)
    end

    private

    def hbinding(frame)
      hash = frame_locals(frame)
      code = hash.keys.map{|k| "#{k} = hash['#{k}']" unless k=='self' }.compact.join(';') + ';binding'
      if obj = frame_self(frame)
        obj.instance_eval code
      else
        eval code, TOPLEVEL_BINDING
      end
    end

    def handler
      Debugger.handler or raise 'No interface loaded'
    end

    def at_breakpoint(breakpoint)
      handler.at_breakpoint(self, breakpoint)
    end

    def at_catchpoint(excpt)
      handler.at_catchpoint(self, excpt)
    end

    def at_tracing(file, line)
      handler.at_tracing(self, file, line)
    end

    def at_line(file, line)
      handler.at_line(self, file, line)
    end

    def at_return(file, line)
      handler.at_return(self, file, line)
    end
  end
  
  @reload_source_on_change = false
  
  class << self
    # interface modules provide +handler+ object
    attr_accessor :handler
    
    # if <tt>true</tt>, checks the modification time of source files and reloads if it was modified
    attr_accessor :reload_source_on_change

    attr_accessor :last_exception
    Debugger.last_exception = nil
    
    #
    # Interrupts the current thread
    #
    def interrupt
      current_context.interrupt
    end
    
    #
    # Interrupts the last debugged thread
    #
    def interrupt_last
      if context = last_context
        return nil unless context.thread.alive?
        context.interrupt
      end
      context
    end
    
    def source_reload
      LineCache::clear_file_cache
    end
    
    # Get line +line_number+ from file named +filename+. Return "\n"
    # there was a problem. Leaking blanks are stripped off.
    def line_at(filename, line_number) # :nodoc:
      @reload_on_change=nil unless defined?(@reload_on_change)
      line = LineCache::getline(filename, line_number, @reload_on_change)
      return "\n" unless line
      return "#{line.gsub(/^\s+/, '').chomp}\n"
    end

    #
    # Activates the post-mortem mode. There are two ways of using it:
    # 
    # == Global post-mortem mode
    # By calling Debugger.post_mortem method without a block, you install
    # at_exit hook that intercepts any unhandled by your script exceptions
    # and enables post-mortem mode.
    #
    # == Local post-mortem mode
    #
    # If you know that a particular block of code raises an exception you can
    # enable post-mortem mode by wrapping this block with Debugger.post_mortem, e.g.
    #
    #   def offender
    #      raise 'error'
    #   end
    #   Debugger.post_mortem do
    #      ...
    #      offender
    #      ...
    #   end
    def post_mortem
      if block_given?
        old_post_mortem = self.post_mortem?
        begin
          self.post_mortem = true
          yield
        rescue Exception => exp
          handle_post_mortem(exp)
          raise
        ensure
          self.post_mortem = old_post_mortem
        end
      else
        return if post_mortem?
        self.post_mortem = true
        debug_at_exit do
          handle_post_mortem($!) if $! && post_mortem?
        end
      end
    end
    
    def handle_post_mortem(exp)
      return if !exp || !exp.__debug_context || 
        exp.__debug_context.stack_size == 0
      Debugger.suspend
      orig_tracing = Debugger.tracing, Debugger.current_context.tracing
      Debugger.tracing = Debugger.current_context.tracing = false
      Debugger.last_exception = exp
      handler.at_line(exp.__debug_context, exp.__debug_file, exp.__debug_line)
    ensure
      Debugger.tracing, Debugger.current_context.tracing = orig_tracing
      Debugger.resume
    end
    # private :handle_post_mortem
  end
  
  class DebugThread # :nodoc:
  end
  
  class ThreadsTable # :nodoc:
  end

  # Debugger.start(options) -> bool
  # Debugger.start(options) { ... } -> obj
  #
  # If it's called without a block it returns +true+, unless debugger
  # was already started.  If a block is given, it starts debugger and
  # yields to block. When the block is finished executing it stops
  # the debugger with Debugger.stop method.
  #
  # If a block is given, it starts debugger and yields to block. When
  # the block is finished executing it stops the debugger with
  # Debugger.stop method. Inside the block you will probably want to
  # have a call to Debugger.debugger. For example:
  #
  #     Debugger.start{debugger; foo}  # Stop inside of foo
  #
  # Also, ruby-debug only allows
  # one invocation of debugger at a time; nested Debugger.start's
  # have no effect and you can't use this inside the debugger itself.
  #
  # <i>Note that if you want to stop debugger, you must call
  # Debugger.stop as many time as you called Debugger.start
  # method.</i>
  # 
  # +options+ is a hash used to set various debugging options.
  # Set :init true if you want to save ARGV and some variables which
  # make a debugger restart possible. Only the first time :init is set true
  # will values get set. Since ARGV is saved, you should make sure 
  # it hasn't been changed before the (first) call. 
  # Set :post_mortem true if you want to enter post-mortem debugging
  # on an uncaught exception. Once post-mortem debugging is set, it can't
  # be unset.
  def start(options={}, &block)
    options = Debugger::DEFAULT_START_SETTINGS.merge(options)
    if options[:init]
      Debugger.const_set('ARGV', ARGV.clone) unless 
        defined? Debugger::ARGV
      Debugger.const_set('PROG_SCRIPT', $0) unless 
        defined? Debugger::PROG_SCRIPT
      Debugger.const_set('INITIAL_DIR', Dir.pwd) unless 
        defined? Debugger::INITIAL_DIR
    end
    Debugger.tracing = options[:tracing] unless options[:tracing].nil?
    retval = Debugger.started? ? block && block.call(self) : Debugger.start_(&block) 
    if options[:post_mortem]
      post_mortem
    end
    return retval
  end
  module_function :start
end

module Kernel

  # Enters the debugger in the current thread after _steps_ line
  # events occur.  Before entering the debugger, a user-defined
  # startup script is may be read.
  #
  # Setting _steps_ to 0 will cause a break in the debugger subroutine
  # and not wait for a line event to occur. You will have to go "up 1"
  # in order to be back in your debugged program rather than the
  # debugger. Settings _steps_ to 0 could be useful you want to stop
  # right after the last statement in some scope, because the next
  # step will take you out of some scope.
  #
  # If block _block_ is given (and the debugger hasn't been started,
  # we run the block under the debugger.  
  #
  # FIXME: Alas, when a block is given, we can't support running the
  # startup script or support the steps option.
  def debugger(steps = 1, &block)
    if block
      Debugger.start({}, &block)
    else
      Debugger.start unless Debugger.started?
      Debugger.run_init_script(StringIO.new)
      if 0 == steps
        Debugger.current_context.stop_frame = 0
      else
        Debugger.current_context.stop_next = steps
      end
    end
  end
  alias breakpoint debugger unless respond_to?(:breakpoint)
  
  #
  # Returns a binding of n-th call frame
  #
  def binding_n(n = 0)
    Debugger.skip do
      Debugger.current_context.frame_binding(n+2)
    end
  end
end

class Exception # :nodoc:
  attr_reader :__debug_file, :__debug_line, :__debug_binding, :__debug_context
end

class Module
  #
  # Wraps the +meth+ method with Debugger.start {...} block.
  #
  def debug_method(meth)
    old_meth = "__debugee_#{meth}"
    old_meth = "#{$1}_set" if old_meth =~ /^(.+)=$/
    alias_method old_meth.to_sym, meth
    class_eval <<-EOD
    def #{meth}(*args, &block)
      Debugger.start do
        debugger 2
        #{old_meth}(*args, &block)
      end
    end
    EOD
  end
  
  #
  # Wraps the +meth+ method with Debugger.post_mortem {...} block.
  #
  def post_mortem_method(meth)
    old_meth = "__postmortem_#{meth}"
    old_meth = "#{$1}_set" if old_meth =~ /^(.+)=$/
    alias_method old_meth.to_sym, meth
    class_eval <<-EOD
    def #{meth}(*args, &block)
      Debugger.start do |dbg|
        dbg.post_mortem do
          #{old_meth}(*args, &block)
        end
      end
    end
    EOD
  end
end
