module Closure

  VERSION           = "1.1.1"

  COMPILER_VERSION  = "20110322"

  JAVA_COMMAND      = 'java'

  COMPILER_ROOT     = File.expand_path(File.dirname(__FILE__))

  COMPILER_JAR      = File.join(COMPILER_ROOT, "closure-compiler-#{COMPILER_VERSION}.jar")

end

require 'stringio'
require File.join(Closure::COMPILER_ROOT, 'closure/popen')
require File.join(Closure::COMPILER_ROOT, 'closure/compiler')