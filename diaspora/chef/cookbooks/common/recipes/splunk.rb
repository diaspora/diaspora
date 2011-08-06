unless system "splunk status"
  execute "Make Temp Dir" do
    command "mkdir -p /tmp/install"
  end

  execute "Download splunk" do
    command "cd /tmp/install && wget 'http://www.splunk.com/index.php/download_track?file=4.1.5/linux/splunk-4.1.5-85165-Linux-x86_64.tgz&ac=&wget=true&name=wget&typed=releases'"
  end

  execute "Untar splunk" do
    command "tar -xvf /tmp/install/splunk-4.1.5-85165-Linux-x86_64.tgz -C /opt/"
  end

  link "/usr/local/bin/splunk" do
    to "/opt/splunk/bin/splunk"
  end
end

execute "Start splunk" do
  command "splunk start --accept-license || true"
end

execute "Put splunk into forwarding mode" do
  command "splunk enable app SplunkLightForwarder -auth admin:changeme"
end

execute "Add forwarding server" do
  command "splunk add forward-server splunk.joindiaspora.com:9997 -auth admin:changeme"
  not_if "splunk list forward-server | grep splunk.joindiaspora.com:9997"
end

execute "Add monitor for diaspora" do
  command "splunk add monitor /usr/local/app/diaspora/log"
  not_if "splunk list monitor | grep diaspora"
end

execute "Add monitor for nginx" do
  command "mkdir -p /usr/local/nginx/logs && splunk add monitor /usr/local/nginx/logs"
  not_if "splunk list monitor | grep nginx"
end

execute 'Splunk Restart' do
  command "splunk restart"
end
