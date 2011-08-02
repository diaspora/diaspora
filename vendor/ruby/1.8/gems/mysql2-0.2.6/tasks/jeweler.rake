begin
  require 'jeweler'
  JEWELER = Jeweler::Tasks.new do |gem|
    gem.name = "mysql2"
    gem.summary = "A simple, fast Mysql library for Ruby, binding to libmysql"
    gem.email = "seniorlopez@gmail.com"
    gem.homepage = "http://github.com/brianmario/mysql2"
    gem.authors = ["Brian Lopez"]
    gem.require_paths = ["lib", "ext"]
    gem.extra_rdoc_files = `git ls-files *.rdoc`.split("\n")
    gem.files = `git ls-files`.split("\n")
    gem.extensions = ["ext/mysql2/extconf.rb"]
    gem.files.include %w(lib/jeweler/templates/.document lib/jeweler/templates/.gitignore)
  end
rescue LoadError
  puts "jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end