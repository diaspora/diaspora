begin
  require "jshintrb/jshinttask"
  Jshintrb::JshintTask.new :jshint do |t|
    t.pattern = "{app/assets,lib/assets,spec}/javascripts/**/*.js"
    t.options = :jshintrc
  end
rescue LoadError
  desc "jshint rake task not available (jshintrb not installed)"
  task :jshint do
    abort "JSHint rake task is not available. Be sure to install jshintrb."
  end
end
