unless defined?(Gem::DocManager.load_yardoc)
  require File.expand_path(File.dirname(__FILE__) + '/yard/rubygems/specification')
  require File.expand_path(File.dirname(__FILE__) + '/yard/rubygems/doc_manager')
end
