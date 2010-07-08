class PersonRequest
  include MongoMapper::Document
  include Diaspora::Webhooks
  include ROXML
  
  xml_name :person_request

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :url, String
  key :person, Person
  
  validates_presence_of :url

  before_save :check_for_person_requests

  def self.for(url)
    request = PersonRequest.new(:url => url)
    request.person = User.first
    request.save

    request.push_to([request])
  end

  def check_for_person_requests
    p = Person.where(:url => self.url).first
    if p
      p.active = true
      p.save
    end
  end

end
