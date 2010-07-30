class Profile
  include MongoMapper::EmbeddedDocument
  require 'lib/diaspora/webhooks'
  include Diaspora::Webhooks
  include ROXML

  xml_reader :person_id
  xml_accessor :first_name
  xml_accessor :last_name
  xml_accessor :image_url
  

  key :first_name, String
  key :last_name, String
  key :image_url, String

  validates_presence_of :first_name, :last_name

  def person_id
    self._parent_document.id
  end
  
  def to_diaspora_xml
    "<post>"+ self.to_xml.to_s + "</post>"
  end
  
end
