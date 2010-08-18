class Group 
  include MongoMapper::Document
  
  key :name, String

  key :person_ids, Array
  key :request_ids, Array
  key :my_post_ids, Array

  many :people, :in => :person_ids, :class_name => 'Person'
  many :requests, :in => :request_ids, :class_name => 'Request'
  many :my_posts, :in => :my_post_ids, :class_name => 'Post'

  belongs_to :user, :class_name => 'User'

  timestamps!

end

