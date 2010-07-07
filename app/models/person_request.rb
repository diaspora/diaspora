class PersonRequest
  include MongoMapper::Document
  include Diaspora::Webhooks
  
  key :url, String

  attr_accessor :sender
  
  validates_presence_of :url

  before_save :check_for_person_requests

  def to_person_xml
    person = Person.new
    person.email = sender.email
    person.url = sender.url
    person.profile = sender.profile.clone

    person.to_xml
  end

  def self.for(url)
    person_request = PersonRequest.new(:url => url)
    person_request.sender = User.first
    person_request.save

    person_request.push_person_request_to_url(person_request.url)
  end

  def check_for_person_requests
    p = Person.where(:url => self.url).first
    if p
      p.active = true
      p.save
    end
  end

end
