JSON_SIMPLE_JAR = ENV['HOME'] + '/.m2/repository/com/googlecode/json-simple/json-simple/1.1/json-simple-1.1.jar'

if defined?(JRUBY_VERSION)
  require JSON_SIMPLE_JAR
end
