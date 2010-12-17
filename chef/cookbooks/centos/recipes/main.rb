def harden_ruby(ruby_string)
  Dir.glob("/usr/local/rvm/wrappers/#{ruby_string}/*").each do |file|
    link "/usr/local/bin/#{file.split('/').last}" do
      to file
    end
  end
  Dir.glob("/usr/local/rvm/gems/#{ruby_string}/bin/*").each do |file|
    link "/usr/local/bin/#{file.split('/').last}" do
      to file
    end
  end

end

harden_ruby("ree-1.8.7-2010.02")

include_recipe "centos::image_magick"
include_recipe "centos::mongo_db"
include_recipe "common::main"
include_recipe "centos::nginx"
include_recipe "centos::redis"
