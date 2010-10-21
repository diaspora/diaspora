require 'fileutils'

Project.configure do |project|
  project.build_command = 'sudo gem update --system && ruby lib/cruise/build.rb'
end
