namespace :accounts do
  desc 'Run deletions'
  task run_deletions: :environment do
    if ::AccountDeletion.uncompleted.count > 0
      puts 'Running account deletions..'
      ::AccountDeletion.uncompleted.find_each(&:perform!)
      puts 'OK.'
    else
      puts 'No acccount deletions to run.'
    end
  end
end
