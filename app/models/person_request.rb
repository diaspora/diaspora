class PersonRequest
  require 'lib/common'
  include ApplicationHelper 
  include MongoMapper::Document
  include ROXML
  include Diaspora::Webhooks


  xml_name :person_request

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :url, String
  key :person, Person
  
  validates_presence_of :url

  before_save :check_for_person_requests

  def self.for(url)
    request = PersonRequest.new(:url => url, :person => User.first)
    request.save
    request.push_to_url(url)
  end

  def check_for_person_requests
    p = Person.where(:url => self.url).first
    if p
      p.active = true
      p.save
    end
  end

end
