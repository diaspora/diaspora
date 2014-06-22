namespace :accounts do
  desc "Run deletions"
  task :run_deletions => :environment do
    if ::AccountDeletion.count > 0
      puts "Running account deletions.."
      ::AccountDeletion.find_each do |account_delete|
        account_delete.perform!
      end
      puts "OK."
    else
      puts "No acccount deletions to run."
    end
  end

end
