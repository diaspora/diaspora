# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
#
# Add a parameterized user to database.

require 'yaml'

def read_password
  begin
    system('stty -echo')
    while true do
      printf 'Enter password: '
      pw1 = $stdin.gets.chomp
      puts
      printf 'Again: '
      pw2 = $stdin.gets.chomp
      puts
      break if pw1 == pw2
      puts "They don't match, try again"
    end
  ensure
    system('stty echo')
  end
  return pw1
end

username = (ARGS[:username] || 'admin').dup
password = ARGS[:password] || read_password
email = ARGS[:email] || "#{username}@#{AppConfig[:pod_uri].host}"
if email =~ /localhost$/
  puts "WARNING: localhost will not validate as an email domain"
  puts "\tupdate your email address, if you require email notifications for this account"
  puts "\trake db:first_user[username,password,email]"
  puts "\trake db:add_user[username,password]"
  puts "\tor modify your data store"
  email = 'username@example.com'
end

user = User.build(:email => email,
                  :username => username,
                  :password => password,
                  :password_confirmation => password,
                  :person => {
                    :profile => {
                      :first_name => username,
                      :last_name => "Unknown",
                      :image_url => "/images/user/default.png"
                    }
                  }
)

user.valid?
errors = user.errors
errors.delete :person
if errors.size > 0
  raise "Error(s) creating user #{username} / #{email}: #{errors.full_messages.to_s}"
end

user.save
user.person.save!
user.seed_aspects
puts "Created user #{username} with email #{email}"
