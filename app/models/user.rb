require 'lib/diaspora/user/friending.rb'

class User
  include MongoMapper::Document
  include Diaspora::UserModules::Friending
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  key :friend_ids, Array
  key :pending_request_ids, Array
  key :visible_post_ids, Array

  one :person, :class_name => 'Person', :foreign_key => :owner_id

  many :friends, :in => :friend_ids, :class_name => 'Person'
  many :pending_requests, :in => :pending_request_ids, :class_name => 'Request'
  many :raw_visible_posts, :in => :visible_post_ids, :class_name => 'Post'

  many :groups, :class_name => 'Group'

  after_validation_on_create :setup_person
  after_create :seed_groups
  after_save :check_for_tommy

  before_validation :do_bad_things 
  ######## Making things work ########
  key :email, String
  validates_true_for :email, :logic => lambda {self.allowed_email? unless email.nil?} 

  
  def allowed_email?
    allowed_emails = ["@pivotallabs.com", "@joindiaspora.com", "@sofaer.net",
      "wchulley@gmail.com", "kimfuh@yahoo.com", "CJichi@yahoo.com",
      "madkisso@mit.edu", "bribak@msn.com", "asykley@verizon.net",
      "paulhaeberli@gmail.com","bondovatic@gmail.com", "dixon1e@yahoo.com"]
    
    allowed_emails.each{|allowed| 
      if email.include?(allowed)
        return true
      end
    }
      false
  end

  ensure_index :email

  def method_missing(method, *args)
    self.person.send(method, *args)
  end

  def real_name
    "#{person.profile.first_name.to_s} #{person.profile.last_name.to_s}"
  end
  
  ######### Groups ######################
  def group( opts = {} )
    opts[:user] = self
    Group.create(opts)
  end

  ######## Posting ########
  def post(class_name, options = {})
    options[:person] = self.person

    group_ids = options[:group_ids]
    options.delete(:group_ids)

    model_class = class_name.to_s.camelize.constantize
    
    post = model_class.instantiate(options)
    post.creator_signature = post.sign_with_key(encryption_key)
    post.save


    groups = self.groups.find_all_by_id(group_ids)
    target_people = [] 

    groups.each{ |group|
      group.posts << post
      group.save
      target_people = target_people | group.people
    }
    
    post.socket_to_uid(id, :group_ids => groups.map{|g| g.id}) if post.respond_to?(:socket_to_uid)
    post.push_to( target_people )

    self.raw_visible_posts << post
    self.save
    post
  end
 
  def visible_posts( opts = {} )
    if opts[:by_members_of]
      return raw_visible_posts if opts[:by_members_of] == :all
      group = self.groups.find_by_id( opts[:by_members_of].id )
      group.posts
    end
  end

  ######## Commenting  ########
  def comment(text, options = {})
    raise "must comment on something!" unless options[:on]
    comment = Comment.new(:person_id => self.person.id, :text => text, :post => options[:on])
    comment.creator_signature = comment.sign_with_key(encryption_key)
    if comment.save
      dispatch_comment comment
      comment.socket_to_uid id
      comment
    else
      Rails.logger.warn "this failed to save: #{comment.inspect}"
      false
    end
  end
  
  def dispatch_comment( comment )
    if owns? comment.post
      comment.post_creator_signature = comment.sign_with_key(encryption_key)
      comment.save
      comment.push_downstream
    elsif owns? comment
      comment.save
      comment.push_upstream
    end
  end
  
  ######### Posts and Such ###############

  def retract( post )
    post.unsocket_from_uid(self.id) if post.respond_to? :unsocket_from_uid
    retraction = Retraction.for(post)
    retraction.creator_signature = retraction.sign_with_key( encryption_key ) 
    retraction.push_to( self.friends.all )
    retraction
  end

  ########### Profile ######################
  def update_profile(params)
    if self.person.update_attributes(params)
      self.profile.push_to( self.friends.all )
      true
    else
      false
    end
  end

  ###### Receiving #######
  def receive xml
    object = Diaspora::Parser.from_xml(xml)
    Rails.logger.debug("Receiving object:\n#{object.inspect}")
    raise "Signature was not valid on: #{object.inspect}" unless object.signature_valid?
    if object.is_a? Retraction
      if object.type == 'Person' && object.signature_valid?

        Rails.logger.info( "the person id is #{object.post_id} the friend found is #{visible_person_by_id(object.post_id).inspect}")
        unfriended_by visible_person_by_id(object.post_id)

      else
        object.perform self.id
        groups = self.groups_with_person(object.person)
        groups.each{ |group| group.post_ids.delete(ensure_bson(object.post_id))
                             group.save
        }
      end
    elsif object.is_a? Request
      person = Diaspora::Parser.get_or_create_person_object_from_xml( xml )
      person.serialized_key ||= object.exported_key
      object.person = person
      object.person.save
      old_request =  Request.first(:id => object.id)
      object.group_id = old_request.group_id if old_request
      object.save
      receive_friend_request(object)
    elsif object.is_a? Profile
      person = Diaspora::Parser.owner_id_from_xml xml
      person.profile = object
      person.save  

    elsif object.is_a?(Comment) 
      dispatch_comment object unless owns?(object)
    else
      Rails.logger.debug("Saving object: #{object}")
      object.user_refs += 1
      object.save
      
      self.raw_visible_posts << object
      self.save

      groups = self.groups_with_person(object.person)
      groups.each{ |group| 
        group.posts << object
        group.save
        object.socket_to_uid(id, :group_id => group.id) if (object.respond_to?(:socket_to_uid) && !self.owns?(object))
      }

    end

  end

  ###Helpers############
  def self.instantiate!( opts = {} )
    opts[:person][:email] = opts[:email]
    opts[:person][:serialized_key] = generate_key
    User.create!( opts)
  end
	 	
  def terse_url
    terse= self.url.gsub(/https?:\/\//, '')
    terse.gsub!(/www\./, '')
    terse = terse.chop! if terse[-1, 1] == '/'
    terse
  end
 
  def do_bad_things
    self.password_confirmation = self.password
  end 

  def visible_person_by_id( id )
    id = ensure_bson id
    return self.person if id == self.person.id
    friends.detect{|x| x.id == id }
  end

  def group_by_id( id )
    id = ensure_bson id
    groups.detect{|x| x.id == id }
  end


  def tommy?
    email.include?("tommy@pivotallabs.com") || email.include?("tsullivan@pivotallabs.com")
  end

  def check_for_tommy
    if tommy?
      person.profile.first_name = "Porn"
      person.profile.last_name = "King"
      person.profile.save
      person.save
    end
  end
  
  def seed_groups
    group(:name => "Acquaintances")
    group(:name => "Family")
    group(:name => "Nemeses")
    group(:name => "Work")
  end

  def album_by_id( id )
    id = ensure_bson id
    albums.detect{|x| x.id == id }
  end

  def groups_with_person person
    id = ensure_bson person.id
    groups.select {|group| group.person_ids.include? id}
  end

  protected
  
  def setup_person
    self.person.serialized_key ||= generate_key.export
    self.person.email ||= email
    self.person.save!
  end

  protected
   def generate_key
    OpenSSL::PKey::RSA::generate 1024 
  end 

  def self.generate_key
    OpenSSL::PKey::RSA::generate 1024 
  end

  def ensure_bson id 
    id.class == String ? BSON::ObjectID(id) : id 
  end
end
