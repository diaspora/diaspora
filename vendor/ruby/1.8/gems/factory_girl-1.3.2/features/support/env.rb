PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

$: << File.join(PROJECT_ROOT, 'lib')

case ENV['RAILS_VERSION']
when '2.1' then
  gem 'activerecord',  '~>2.1.0'
when '3.0' then
  gem 'activerecord',  '~>3.0.0'
else
  gem 'activerecord',  '~>2.3.0'
end

require 'active_record'
require 'factory_girl'
