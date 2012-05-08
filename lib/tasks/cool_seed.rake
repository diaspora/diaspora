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

      if post['photo'].present? 
        new_photo = Factory.build(:photo)
        new_photo.remote_processed_image_url = post['photo']
        new_photo.remote_unprocessed_image_url = post['photo']
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
  puts first, last
  user =  User.find_by_username(first)
  return user if user.present?
  puts Person.all.inspect
  person = Factory.build(:person, :diaspora_handle => "#{first}@diaspora.dev")
  person.save!
  profile = Factory(:profile, :first_name => first, :last_name => last, :person => person)


  user = Factory.build(:user, :username => first)
  user.person = person
  person.save!

  person.profile.destroy
  person.profile = profile
  profile.person_id = person.id
  profile.save! 

  user.save(:validate => false)
  user
end
