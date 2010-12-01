require 'rubygems'
require 'tcl'

Before do
  @fib = Tcl::Interp.load_from_file(File.dirname(__FILE__) + '/../../src/fib.tcl')
end
