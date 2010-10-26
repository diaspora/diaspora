require 'fileutils'

Project.configure do |project|
  project.build_command = './ci.sh'
  project.do_clean_checkout :always
end
