desc 'Seeds cool users'
task :cool => :environment do
  require 'factory_girl_rails'
  cool_people_yml = YAML.load(File.open(File.join(Rails.root, 'config', 'cool_people.yml')))

  cool_people_yml.each do |name, attributes|

    puts "making #{name}"
    user = make_user_with_name(attributes['name'])
    attributes['posts'].shuffle.each do |post|
      new_post = Factory.build(:status_message, :public => true, :text => '', :author => user.person)
      new_post.text = post.fetch('text', '')

      if p = post['photo'] 
        new_photo = Factory.build(:photo)
        new_photo.processed_image_url = p
        new_photo.save
        new_photo.update_remote_path
        new_post.photos << new_photo
        new_photo.save
      end
      #wut to do with videos :(
      new_post.save
      puts "made: #{post}"
    end
  end
end

def make_user_with_name(name)
  first, last = name.split
  return user if user =  User.find_by_username(first)
  person = Factory.build(:person)
  person.save!
  profile = Factory(:profile, :first_name => first, :last_name => last, :person => person)


  user = Factory.build(:user, :username => first)
  user.person = person
  person.save!

  person.profile.destroy
  person.profile = profile
  profile.person_id = person.id
  profile.save

  user.save
  user
end
