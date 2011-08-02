require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'hmac'

Hoe.spec 'ruby-hmac' do
  developer "Daiki Ueno", ""
  developer "Geoffrey Grosenbach", "boss@topfunky.com"
end

Hoe.plugin :minitest
Hoe.plugin :git
Hoe.plugin :gemcutter

desc "Simple require on packaged files to make sure they are all there"
task :verify => :package do
  # An error message will be displayed if files are missing
  if system %(ruby -e "require 'pkg/ruby-hmac-#{HMAC::VERSION}/lib/hmac'")
    puts "\nThe library files are present"
  end
end

task :release => :verify
