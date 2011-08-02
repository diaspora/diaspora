#!/usr/bin/env ruby
# -*- Ruby -*-
# This is a hacked down copy of rdebug which can be used for testing
# FIXME: use the real rdebug script - DRY.

require 'stringio'
require 'rubygems'
require 'optparse'
require "ostruct"

TOP_SRC_DIR = File.join(File.dirname(__FILE__), "..") unless 
  defined?(TOP_SRC_DIR)

$:.unshift File.join(TOP_SRC_DIR, "ext")
$:.unshift File.join(TOP_SRC_DIR, "lib")
$:.unshift File.join(TOP_SRC_DIR, "cli")

def debug_program(options)
  # Make sure Ruby script syntax checks okay.
  # Otherwise we get a load message that looks like rdebug has 
  # a problem. 
  output = `ruby -c #{Debugger::PROG_SCRIPT.inspect} 2>&1`
  if $?.exitstatus != 0 and RUBY_PLATFORM !~ /mswin/
    puts output
    exit $?.exitstatus 
  end
  print "\032\032starting\n" if Debugger.annotate and Debugger.annotate > 2
  unless options.no_rewrite_program
    # Set $0 so things like __FILE == $0 work.
    # A more reliable way to do this is to put $0 = __FILE__ *after*
    # loading the script to be debugged.  For this, adding a debug hook
    # for the first time and then switching to the debug hook that's
    # normally used would be helpful. Doing this would also help other
    # first-time initializations such as reloading debugger state
    # after a restart. 

    # However This is just a little more than I want to take on right
    # now, so I think I'll stick with the slightly hacky approach.
    $RDEBUG_0 = $0

    # cygwin does some sort of funky truncation on $0 ./abcdef => ./ab
    # probably something to do with 3-letter extension truncation.
    # The hacky workaround is to do slice assignment. Ugh.
    d0 = if '.' == File.dirname(Debugger::PROG_SCRIPT) and
             Debugger::PROG_SCRIPT[0..0] != '.'
           File.join('.', Debugger::PROG_SCRIPT)
         else
           Debugger::PROG_SCRIPT
         end
    if $0.frozen?
      $0 = d0
    else
      $0[0..-1] = d0
    end
  end

  # Record where we are we can know if the call stack has been
  # truncated or not.
  Debugger.start_sentinal=caller(0)[1]

  bt = Debugger.debug_load(Debugger::PROG_SCRIPT, !options.nostop, false)
  if bt
    if options.post_mortem
      Debugger.handle_post_mortem(bt)
    else
      print bt.backtrace.map{|l| "\t#{l}"}.join("\n"), "\n"
      print "Uncaught exception: #{bt}\n"
    end
  end
end

options = OpenStruct.new(
  'annotate'    => false,
  'emacs'       => false,
  'frame_bind'  => false,
  'no-quit'     => false,
  'no-stop'     => false,
  'nx'          => false,
  'post_mortem' => false,
  'script'      => nil,
  'tracing'     => false,
  'verbose_long'=> false,
  'wait'        => false
)

require "ruby-debug"

program = File.basename($0)
opts = OptionParser.new do |opts|
  opts.banner = <<EOB
#{program} #{Debugger::VERSION}
Usage: #{program} [options] <script.rb> -- <script.rb parameters>
EOB
  opts.separator ""
  opts.separator "Options:"
  opts.on("-A", "--annotate LEVEL", Integer, "Set annotation level") do 
    |Debugger.annotate|
  end
  opts.on("-d", "--debug", "Set $DEBUG=true") {$DEBUG = true}
  opts.on("--emacs-basic", "Activates basic Emacs mode") do 
    ENV['EMACS'] = '1'
    options.emacs = true
  end
  opts.on("--keep-frame-binding", "Keep frame bindings") do 
    options.frame_bind = true
  end
  opts.on("-m", "--post-mortem", "Activate post-mortem mode") do 
    options.post_mortem = true
  end
  opts.on("--no-control", "Do not automatically start control thread") do 
    options.control = false
  end
  opts.on("--no-quit", "Do not quit when script finishes") do
    options.noquit = true
  end
  opts.on("--no-stop", "Do not stop when script is loaded") do 
    options.nostop = true
  end
  opts.on("-nx", "Not run debugger initialization files (e.g. .rdebugrc") do
    options.nx = true
  end
  opts.on("-I", "--include PATH", String, "Add PATH to $LOAD_PATH") do |path|
    $LOAD_PATH.unshift(path)
  end
  opts.on("-r", "--require SCRIPT", String,
          "Require the library, before executing your script") do |name|
    if name == 'debug'
      puts "ruby-debug is not compatible with Ruby's 'debug' library. This option is ignored."
    else
      require name
    end
  end
  opts.on("--script FILE", String, "Name of the script file to run") do |options.script| 
    unless File.exists?(options.script)
      puts "Script file '#{options.script}' is not found"
      exit
    end
  end
  opts.on("-x", "--trace", "Turn on line tracing") {options.tracing = true}
  ENV['EMACS'] = nil unless options.emacs
  opts.separator ""
  opts.separator "Common options:"
  opts.on_tail("--help", "Show this message") do
    puts opts
    exit
  end
  opts.on_tail("--version", 
               "Print the version") do
    puts "ruby-debug #{Debugger::VERSION}"
    exit
  end
  opts.on("--verbose", "Turn on verbose mode") do
    $VERBOSE = true
    options.verbose_long = true
  end
  opts.on_tail("-v", 
               "Print version number, then turn on verbose mode") do
    puts "ruby-debug #{Debugger::VERSION}"
    $VERBOSE = true
  end
end

begin
  if not defined? Debugger::ARGV
    Debugger::ARGV = ARGV.clone
  end
  rdebug_path = File.expand_path($0)
  if RUBY_PLATFORM =~ /mswin/
    rdebug_path += '.cmd' unless rdebug_path =~ /\.cmd$/i
  end
  Debugger::RDEBUG_SCRIPT = rdebug_path
  Debugger::RDEBUG_FILE = __FILE__
  Debugger::INITIAL_DIR = Dir.pwd
  opts.parse! ARGV
rescue StandardError => e
  puts opts
  puts
  puts e.message
  exit(-1)
end

if ARGV.empty?
  exit if $VERBOSE and not options.verbose_long
  puts opts
  puts
  puts 'Must specify a script to run'
  exit(-1)
end
  
# save script name
Debugger::PROG_SCRIPT = ARGV.shift

# install interruption handler
trap('INT') { Debugger.interrupt_last }

# set options
Debugger.wait_connection = false
Debugger.keep_frame_binding = options.frame_bind

# Add Debugger trace hook.
Debugger.start

# start control thread
Debugger.start_control(options.host, options.cport) if options.control

# activate post-mortem
Debugger.post_mortem if options.post_mortem

# Set up an interface to read commands from a debugger script file.
if options.script
  Debugger.interface = Debugger::ScriptInterface.new(options.script, 
                                                     STDOUT, true)
end
options.nostop = true if options.tracing
Debugger.tracing = options.tracing

# Make sure Ruby script syntax checks okay.
# Otherwise we get a load message that looks like rdebug has 
# a problem. 
output = `ruby -c #{Debugger::PROG_SCRIPT.inspect} 2>&1`
if $?.exitstatus != 0 and RUBY_PLATFORM !~ /mswin/
  puts output
  exit $?.exitstatus 
end

# load initrc script (e.g. .rdebugrc)
Debugger.run_init_script(StringIO.new) unless options.nx

# run startup script if specified
if options.script
  Debugger.run_script(options.script)
end
# activate post-mortem
Debugger.post_mortem if options.post_mortem
options.stop = false if options.tracing
Debugger.tracing = options.tracing

if options.noquit
  if Debugger.started?
    until Debugger.stop do end
  end
  debug_program(options)
  print "The program finished.\n" unless 
    Debugger.annotate.to_i > 1 # annotate has its own way
  interface = Debugger::LocalInterface.new
  # Not sure if ControlCommandProcessor is really the right
  # thing to use. CommandProcessor requires a state.
  processor = Debugger::ControlCommandProcessor.new(interface)
  processor.process_commands
else
  debug_program(options)
end
