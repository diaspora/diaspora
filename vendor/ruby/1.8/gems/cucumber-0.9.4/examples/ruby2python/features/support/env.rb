require 'rubypython'

ENV['PYTHONPATH'] = File.expand_path(File.dirname(__FILE__) + '/../../lib')

Before do
  RubyPython.start
  @fib = RubyPython.import('fib')
end

After do
  RubyPython.stop
end

# RubyPython seems to expect this to exist (?)
class String
  def end_with?(str)
    str = str.to_str
    tail = self[-str.length, str.length]
    tail == str
  end
end