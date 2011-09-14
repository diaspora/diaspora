include_recipe "diaspora::image_magick"
include_recipe "diaspora::mysql"
include_recipe "diaspora::iptables"
include_recipe "diaspora::daemontools"
include_recipe "diaspora::splunk"
include_recipe "diaspora::backup"
include_recipe "diaspora::nginx"
include_recipe "diaspora::redis"
include_recipe "diaspora::curl" if platform?("centos")
