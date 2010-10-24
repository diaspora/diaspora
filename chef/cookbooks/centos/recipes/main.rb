execute "say hello" do
  command "echo welcome to diaspora chef"
end

include_recipe "centos::image_magick"
include_recipe "centos::mongo_db"
