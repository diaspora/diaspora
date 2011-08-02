if defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby"
  require 'gherkin/native/ikvm'
elsif defined?(JRUBY_VERSION)
  require 'gherkin/native/java'
else
  require 'gherkin/native/null'
end