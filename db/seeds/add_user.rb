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

def read_email
  printf 'Enter email: '
  email = $stdin.gets.chomp
end

username = ARGS[:username] || 'admin'
password = ARGS[:password] || read_password
if ARGS[:email].nil?
  host = AppConfig[:pod_uri].host
  if host == "localhost"
    email = read_email
  else
    email = "#{username}@#{host}"
  end
else
  email = ARGS[:email]
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
