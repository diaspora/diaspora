desc "revert custom landing page commit after heroku san deploys"
task :after_deploy => :environment do

  # Perform this task only if custom landing page is not present in app/views/home/_show.html.haml
  if File.exist?(File.join(Rails.root, "app", "views", "home", "_show.html.haml")) && system("git log | head -5 | grep 'custom\ landing\ page'")
    puts "-----> resetting HEAD before custom landing page commit"

    system("git reset HEAD^") ? true : fail
    system("git stash pop") unless @did_not_stash

    puts "-----> done"
  end

end
