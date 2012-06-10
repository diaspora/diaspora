desc 'Seeds Admins'
task :create_admin, [:username, :password] => :environment  do |t, args|
  require 'factory_girl_rails'

  puts "making #{args[:username]}"
  user = make_user_with_atts(args[:username], args[:password])
  puts "giving #{args[:username]} admin access"
  flag = make_admin(user)
  if flag
    puts "success"
  else
    puts "fail"
  end
    
end

def make_user_with_atts(username, password)
  user =  User.find_by_username(username)
  return user if user.present?
  puts Person.all.inspect
  person = Factory.build(:person, :diaspora_handle => "#{username}@diaspora.dev")
  person.save!
  profile = Factory(:profile, :first_name => username, :last_name => 'admin', :person => person)


  user = Factory.build(:user, :username => username)
  user.person = person
  user.password = password
  user.password_confirmation = password
  person.save!

  person.profile.destroy
  person.profile = profile
  profile.person_id = person.id
  profile.save! 

  user.save(:validate => false)
  user
end

def make_admin(user)
  role = Role.new
  role.name = "admin"
  role.person_id = user.id
  if role.save
    true
  else
    false
  end
end
