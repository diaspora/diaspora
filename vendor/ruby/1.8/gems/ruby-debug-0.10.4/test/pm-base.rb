#!/usr/bin/env ruby
# Test post-mortem handling using only ruby-debug-base.
src_dir = File.dirname(__FILE__)
%w(ext lib cli).each do |dir|
  $:.unshift  File.join(src_dir, '..', dir)
end
require 'ruby-debug-base'

class CommandProcessor
  def at_line(context, file, line)
    puts 'file: %s, line: %s' % [ File.basename(file), line ]
    exit!
  end
end

Debugger.start(:post_mortem => true)
Debugger.handler = CommandProcessor.new
def zero_div
  1/0
end
zero_div

