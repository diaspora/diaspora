#!/usr/bin/env ruby

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug' ; Debugger.start

TEST_DIR = File.expand_path(File.dirname(__FILE__))
TOP_SRC_DIR = File.join(TEST_DIR, '..')
require File.join(TOP_SRC_DIR, 'lib', 'tracelines.rb')

def dump_file(file, opts)
  puts file
  begin
    fp = File.open(file, 'r')
  rescue Errno::ENOENT
    puts "File #{file} is not readable."
    return
  end
  lines = fp.read
  if opts[:print_source]
    puts '=' * 80
    puts lines
  end
  if opts[:print_parse]
    puts '=' * 80
    cmd = "#{File.join(TEST_DIR, 'parse-show.rb')} #{file}"
    system(cmd)
  end
  if opts[:print_trace]
    require 'tracer'
    puts '=' * 80
    tracer = Tracer.new
    tracer.add_filter lambda {|event, f, line, id, binding, klass|
      __FILE__ != f && event == 'line'
    }
    tracer.on{load(file)}
  end
  expected_lnums = nil
  if opts[:expect_line]
    fp.rewind
    first_line = fp.readline.chomp
    expected_str = first_line[1..-1]
    begin
      expected_lnums = eval(expected_str, binding, __FILE__, __LINE__)
    rescue SyntaxError
      puts '=' * 80
      puts "Failed reading expected values from #{file}"
    end
  end
  fp.close()
  got_lnums = TraceLineNumbers.lnums_for_str(lines)
  if expected_lnums
    puts "expecting: #{expected_lnums.inspect}"
    puts '-' * 80
    if expected_lnums 
      if got_lnums != expected_lnums
        puts "mismatch: #{got_lnums.inspect}"
      else
        puts 'Got what was expected.'
      end
    else
      puts got_lnums.inspect
    end
  else
    puts got_lnums.inspect
  end
end

require 'getoptlong'
program = File.basename($0)
opts = {
  :print_source => true,  # Print source file? 
  :print_trace  => true,  # Run Tracer over file? 
  :expect_line  => true,  # Source file has expected (correct) list of lines?
  :print_parse  => true,  # Show ParseTree output?
}

getopts = GetoptLong.new(
                         [ '--expect',      '-e', GetoptLong::NO_ARGUMENT ],
                         [ '--no-expect',   '-E', GetoptLong::NO_ARGUMENT ],
                         [ '--help',        '-h', GetoptLong::NO_ARGUMENT ],
                         [ '--parse',       '-p', GetoptLong::NO_ARGUMENT ],
                         [ '--no-parse',    '-P', GetoptLong::NO_ARGUMENT ],
                         [ '--source',      '-s', GetoptLong::NO_ARGUMENT ],
                         [ '--no-source',   '-S', GetoptLong::NO_ARGUMENT ],
                         [ '--trace',       '-t', GetoptLong::NO_ARGUMENT ],
                         [ '--no-trace',    '-T', GetoptLong::NO_ARGUMENT ])

getopts.each do |opt, arg|
  case opt
    when '--help'
    puts "usage 
Usage: #{$program} [options] file1 file2 ...

Diagnostic program to make see what TraceLineNumbers does and compare
against other output.

options:
    -e --expect      Read source file expected comment (default)
    -E --no-expect   Don't look for source file expected comment
    -p --parse       Show ParseTree Output (default)
    -P --no-parse    Don't show ParseTree output
    -s --source      Show source file (default)
    -S --no-source   Don't print source
    -t --trace       Show Tracer output (default)
    -T --no-trace    Don't show Tracer output
"
  when '--expect'
    opts[:expect_line] = true
  when '--no-expect'
    opts[:expect_line] = false
  when '--parse'
    opts[:print_parse] = true
  when '--no-parse'
    opts[:print_parse] = false
  when '--source'
    opts[:print_source] = true
  when '--no-source'
    opts[:print_source] = false
  when '--trace'
    opts[:print_trace] = true
  when '--no-trace'
    opts[:print_trace] = false
  else
    puts "Unknown and ignored option #{opt}"
  end
end

ARGV.each do |file| 
  dump_file(file, opts)
end
