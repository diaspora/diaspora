#!/usr/bin/env ruby
#!/usr/bin/env ruby
# $Id: rdbg.rb 756 2008-03-13 02:15:04Z rockyb $

# Use this to run rdebug without installing it.  We assume that the
# library directories are stored at the same level the directory
# this program. 
module RDebugRunner
  def runner(stdout=nil)

    # Add libraries to load path.
    dirname=File.dirname(__FILE__)
    libs = %w(ext lib cli)
    libs.each { |lib| $:.unshift File.join(dirname, lib) }

    rdebug=ENV['RDEBUG'] || File.join(dirname, 'bin', 'rdebug')
    if stdout
      old_stdout = $stdout
      $stdout.reopen(stdout)
    else
      old_stdout = nil
    end
    load(rdebug, true)
    $stdout.reopen(old_stdout) if old_stdout
    
    # Remove those libraries we just added.
    1.upto(libs.size) {$:.shift}
  end
  module_function :runner
end
if __FILE__ == $0 
  RDebugRunner.runner
end
