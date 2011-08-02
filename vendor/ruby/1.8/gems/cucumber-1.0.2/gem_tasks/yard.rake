require 'yard'
require 'yard/rake/yardoc_task'
require 'cucumber/platform'

YARD::Templates::Engine.register_template_path(File.expand_path(File.join(File.dirname(__FILE__), 'yard')))
YARD::Rake::YardocTask.new(:yard) do |t|
  t.options = %w{--no-private --title Cucumber}
  t.files = %w{lib - README.md History.md LICENSE}
end

desc "Push yardoc to http://cukes.info/cucumber/api/#{Cucumber::VERSION}"
task :push_yard => :yard do
  sh("tar czf api-#{Cucumber::VERSION}.tgz -C doc .")
  sh("scp api-#{Cucumber::VERSION}.tgz cukes.info:/var/www/cucumber/api/ruby")
  sh("ssh cukes.info 'cd /var/www/cucumber/api/ruby && rm -rf #{Cucumber::VERSION} && mkdir #{Cucumber::VERSION} && tar xzf api-#{Cucumber::VERSION}.tgz -C #{Cucumber::VERSION} && rm -f latest && ln -s #{Cucumber::VERSION} latest'")
end

task :release => :push_yard