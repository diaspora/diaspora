class Profile
  include MongoMapper::EmbeddedDocument
  include ROXML

  xml_accessor :first_name
  xml_accessor :last_name

  key :first_name, String
  key :last_name, String

  validates_presence_of :first_name, :last_name

end
