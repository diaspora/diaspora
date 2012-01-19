desc "include custom landing page before heroku san deploys"
task :before_deploy => :environment do

  # Perform this task only if custom landing page is not present in app/views/home/_show.html.haml
  if File.exist?(File.join(Rails.root, "app", "views", "home", "_show.html.haml"))
    puts "-----> custom landing page detected..."

    puts "-----> including custom landing page in a temp commit"

    system("git add app/views/home/_show.html.haml -f") ? true : fail
    system("git commit -m 'adding custom landing page for heroku'") ? true : fail

    puts "-----> done"
  end

end
