desc 'Seeds Admins'
task :admin => :environment do
  require 'factory_girl_rails'
  admin_yml = YAML.load(File.open(File.join(Rails.root, 'config', 'admin.yml')))

  admin_yml.each do |name, attributes|

    puts "making #{name}"
    user = make_user_with_atts(attributes['name'], attributes['username'],attributes['password'])
    puts "giving #{name} admin access"
    flag = make_admin(user)
    if flag
      puts "success"
    else
      puts "fail"
    end
    
  end
end

def make_user_with_atts(name, username, password)
  first, last = name.split
  puts first, last
  user =  User.find_by_username(username)
  return user if user.present?
  puts Person.all.inspect
  person = Factory.build(:person, :diaspora_handle => "#{first}@diaspora.dev")
  person.save!
  profile = Factory(:profile, :first_name => first, :last_name => last, :person => person)


  user = Factory.build(:user, :username => first)
  user.person = person
  user.username = username
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
