#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
#   Add a parameterized user to database.
#
#

require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
require File.join(File.dirname(__FILE__), '..', '..','config', 'initializers', '_load_app_config.rb')
require 'yaml'

def read_password

    begin
        system('stty -echo')
        while true do
            printf 'Enter password: '
            pw1 = $stdin.gets.chomp
            puts
            if pw1.length < 6
               puts "Too short (minimum 6 characters)"
               next
            end
            printf 'Again: '
            pw2 = $stdin.gets.chomp
            puts
            break  if pw1 == pw2
            puts "They don't match, try again"
        end
    ensure
        system('stty echo')
    end
    return pw1
end

username = ( ARGS[:username] == nil ? 'admin' :  ARGS[:username].dup)

if ARGS[:email] == nil
    config = YAML.load(File.read(Rails.root.join('config',
                                                 'app_config.yml')))
    email = username + '@' + config['default']['pod_url']
else
    email = ARGS[:email]
end

if ARGS[:password] == nil
    password = read_password
else
    password = ARGS[:password]
end

#printf "Building: %s, %s, '%s'\n", username, email, password

user = User.build(  :email => email,
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

errors = user.errors
errors.delete :person
if errors.size > 0
   raise  "Error(s) creating user " + username + ": " + errors.to_s
end

user.save
user.person.save!
user.seed_aspects
puts "Created user " + username + ' (' + email + ')'
