require 'fileutils'

Project.configure do |project|
  project.build_command = 'source /usr/local/rvm/scripts/rvm && rvm use ruby-1.8.7-p249@diaspora && rm Gemfile.lock && gem update --system && ruby lib/cruise/build.rb'
end
