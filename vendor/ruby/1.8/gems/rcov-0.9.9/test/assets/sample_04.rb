$: << File.dirname(__FILE__)
require 'sample_03'

klass = Rcov::Test::Temporary::Sample03
obj = klass.new
obj.f1
obj.f2
obj.f3
#klass.g1 uncovered
klass.g2
