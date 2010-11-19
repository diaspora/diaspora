execute "Remove Any Pervious Cronjob" do
  command "crontab -r || true" 
end

execute "Add the current cronjob" do
  command "crontab /usr/local/app/diaspora/chef/files/default/backupcorn.txt"
end
