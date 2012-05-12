desc "include custom landing page before heroku san deploys"
task :before_deploy => :environment do

    each_heroku_app do |stage|
      desktop_home_file = stage.config['HOME_FILE_DESKTOP']
      mobile_home_file = stage.config['HOME_FILE_MOBILE']
      # Perform this task only if custom landing page is not present in app/views/home/_show.html.haml
    if desktop_home_file.present? || mobile_home_file.present?
      puts "-----> custom landing page(s) detected..."
      puts "-----> including custom landing page(s) in a temp commit"

      @did_not_stash = system("git stash| grep 'No local changes to save'")      
      system("git add #{desktop_home_file} -f") ? true : fail
      system("git add #{mobile_home_file} -f") ? true : fail
      system("git commit -m 'adding custom landing page(s) for heroku'") ? true : fail

      puts "-----> done"
    end
  end

end
