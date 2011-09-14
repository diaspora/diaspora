package "imagemagick" do
  case node['platform']
  when "debian"
    package_name "imagemagick"
  when "centos"
    package_name "ImageMagick"
  end
end

if platform?("debian")
  package "libmagick9-dev"
end
