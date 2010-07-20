class Collection
  include MongoMapper::Document

  key :name, String

  belongs_to :person, :class_name => 'Person'

  validates_presence_of :name

  #many :posts, :class_name => 'Post', :foreign_key => :collection_id


end
