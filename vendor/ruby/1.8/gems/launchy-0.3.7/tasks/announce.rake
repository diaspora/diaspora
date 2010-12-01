require 'tasks/config'
#-------------------------------------------------------------------------------
# announcement methods
#-------------------------------------------------------------------------------

proj_config = Configuration.for('project')
namespace :announce do
  desc "create email for ruby-talk"
  task :email do
    info = Utils.announcement

    File.open("email.txt", "w") do |mail|
      mail.puts "From: #{proj_config.author} <#{proj_config.email}>"
      mail.puts "To: ruby-talk@ruby-lang.org"
      mail.puts "Date: #{Time.now.rfc2822}"
      mail.puts "Subject: [ANN] #{info[:subject]}"
      mail.puts
      mail.puts info[:title]
      mail.puts 
      mail.puts "  gem install #{Launchy::GEM_SPEC.name}"
      mail.puts
      mail.puts info[:urls]
      mail.puts 
      mail.puts info[:description]
      mail.puts 
      mail.puts "{{ Release notes for Version #{Launchy::VERSION} }}"
      mail.puts 
      mail.puts info[:release_notes]
      mail.puts
    end 
    puts "Created the following as email.txt:"
    puts "-" * 72
    puts File.read("email.txt")
    puts "-" * 72
  end 

  CLOBBER << "email.txt"
end

