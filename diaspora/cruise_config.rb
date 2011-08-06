require 'fileutils'

Project.configure do |project|
  project.build_command = './ci.sh'
end
