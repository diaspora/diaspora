#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
#   Add a parameterized user to database.
#
#
#

config_path = File.join (File.dirname(__FILE__), '..', '..', 'config')

require File.join(config_path, 'environment')
require File.join(config_path, 'initializers', '_load_app_config.rb')

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

password = (ARGS[:password] == nil ? read_password : ARGS[:password])

user = User.build( :email => email,
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
