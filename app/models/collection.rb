class Collection
  include MongoMapper::Document

  key :name, String

  belongs_to :person, :class_name => 'Person'
  #many :photos, :class_name => 'Photo', :foreign_key => :collection_id

  validates_presence_of :name

end
