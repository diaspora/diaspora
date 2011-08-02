# Some common routines used in testing.

require 'fileutils'
require 'yaml'
# require 'diff/lcs'
# require 'diff/lcs/hunk'

# begin require 'rubygems' rescue LoadError end
# require 'ruby-debug'; Debugger.start

module TestHelper

  # FIXME: turn args into a hash.
  def run_debugger(testname, args='', outfile=nil, filter=nil, old_code=false,
                   debug_pgm='tdebug.rb')
    rightfile = File.join('data', "#{testname}.right")
    
    outfile = "#{testname}.out" unless outfile

    if File.exists?(outfile)
      FileUtils.rm(outfile)
    end
    
    ENV['RDEBUG'] = debug_pgm
    ENV['TERM']   = ''

    # The EMACS environment variable(s) cause output to 
    # get prefaced with null which will mess up file compares.
    # So turn off EMACS output processing.
    ENV['EMACS'] = ENV['INSIDE_EMACS'] = nil

    if old_code
      cmd = "/bin/sh #{File.join('..', 'runner.sh')} #{args} >#{outfile}"
    else
      cmd = "#{"#{load_ruby} #{load_params} "}../rdbg.rb #{args} > #{outfile}"
    end
    puts "'#{cmd}'" if $DEBUG
    output = `#{cmd}`
    
    got_lines     = File.read(outfile).split(/\n/)
    correct_lines = File.read(rightfile).split(/\n/)
    filter.call(got_lines, correct_lines) if filter
    if cheap_diff(got_lines, correct_lines)
      FileUtils.rm(outfile)
      return true
    end
    return false
  end

  def cheap_diff(got_lines, correct_lines)
    if $DEBUG
      got_lines.each_with_index do |line, i|
        printf "%3d %s\n", i+1, line
      end
    end
    correct_lines.each_with_index do |line, i|
      correct_lines[i].chomp!
      if got_lines[i] != correct_lines[i]
        puts "difference found at line #{i+1}"
        puts "got : #{got_lines[i]}"
        puts "need: #{correct_lines[i]}"
        return false
      end
    end
    if correct_lines.size != got_lines.size
      puts("difference in number of lines: " + 
           "#{correct_lines.size} vs. #{got_lines.size}")
      return false
    end
    return true
  end

  # FIXME: using this causes the same test to get run several times 
  # and some tests fail probably because of a lack of environment isolation.
  # Many tests follow a basic pattern: run the debugger with a given
  # debugger script and compare output produced. The following creates
  # this kind of test.
  def add_test(base_name, src_dir, script_name=nil, cmd=nil, test_name=nil)
    puts "+++ Adding #{base_name} ++++" if $DEBUG
    test_name   = base_name unless test_name
    script_name = File.join('data', test_name + '.cmd') unless script_name
    cmd         = 'gcd.rb 3 5' unless cmd
    eval <<-EOF
    def test_#{test_name}
      Dir.chdir(\"#{src_dir}\") do 
        assert_equal(true, 
                     run_debugger(\"#{base_name}\", 
                                  \"--script #{script_name} -- #{cmd}\"))
      end
    end
    EOF
  end
  module_function :add_test
               
  # Adapted from the Ruby Cookbook, Section 6.10: Comparing two files.
  # def diff_as_string(rightfile, checkfile, format=:unified, context_lines=3)
  #   right_data = File.read(rightfile)
  #   check_data = File.read(checkfile)
  #   output = ''
  #   diffs = Diff::LCS.diff(right_data, check_data)
  #   return output if diffs.empty?
  #   oldhunk = hunk = nil
  #   file_length_difference = 0
  #   diffs.each do |piece|
  #     begin
  #       hunk = Diff::LCS::Hunk.new(right_data, check_data, piece, 
  #                                  context_lines, file_length_difference)
  #       next unless oldhunk
  #
  #       # Hunks may overlap, which is why we need to be careful when our
  #       # diff includes lines of context. Otherwise, we might print
  #       # redundant lines.
  #       if (context_lines > 0) and hunk.overlaps?(oldhunk)
  #         hunk.unshift(oldhunk)
  #         else
  #         output << oldhunk.diff(format)
  #       end
  #     ensure
  #       oldhunk = hunk
  #       output << '\n'
  #     end
  #   end
  
  #   # Handle the last remaining hunk 
  #   output << oldhunk.diff(format) << '\n'
  # end
  
  # Loads key from the _config_._yaml_ file.
  def config_load(key, may_be_nil=false, default_value='')
    conf = File.join('config.private.yaml') # try private first
    conf = File.join('config.yaml') unless File.exists?(conf)
    value = YAML.load_file(conf)[key]
    assert_not_nil(value, "#{key} is set in config.yaml") unless may_be_nil
    value || default_value
  end
  module_function :config_load

  def load_ruby
    config_load('ruby', true)
  end
  module_function :load_ruby

  def load_params
    config_load('ruby_params', true)
  end
  module_function :load_params
  
end

