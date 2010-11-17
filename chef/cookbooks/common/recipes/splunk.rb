execute "Download splunk" do
  command "cd /tmp/install && wget 'http://www.splunk.com/index.php/download_track?file=4.1.5/linux/splunk-4.1.5-85165-Linux-x86_64.tgz&ac=&wget=true&name=wget&typed=releases'"
end

execute "Untar splunk" do
  command "cd /tmp/install && tar -xvf splunk-4.1.5-85165-Linux-x86_64.tgz"
end

execute "Install splunk" do
  command "mv /tmp/install/splunk /opt/splunk"
end

execute "Put splunk into forwarding mode" do
  command "cd /opt/splunk/bin && ./splunk enable app SplunkLightForwarder -auth admin:changeme"
end

execute "Add forwarding server" do
  command "cd /opt/splunk/bin && ./splunk add forward-server splunk.joindiaspora.com:9997 -auth admin:changeme"
end

execute "Start splunk" do
  command "cd /opt/splunk/bin && ./splunk start"
end
