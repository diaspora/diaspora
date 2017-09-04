# frozen_string_literal: true

begin
  require "eslintrb/eslinttask"
  Eslintrb::EslintTask.new :eslint do |t|
    t.pattern = "{app/assets,lib/assets,spec}/javascripts/**/*.js"
    t.exclude_pattern = "app/assets/javascripts/{jasmine-load-all,main,mobile/mobile,templates}.js"
    t.options = :eslintrc
  end
rescue LoadError
  desc "eslint rake task not available (eslintrb not installed)"
  task :eslint do
    abort "ESLint rake task is not available. Be sure to install eslintrb."
  end
end
