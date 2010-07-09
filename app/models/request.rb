class Request
  include MongoMapper::Document
  include Diaspora::Webhooks
  include ROXML

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :destination_url, String
  key :callback_url, String
  key :person, Person
  
  validates_presence_of :destination_url, :callback_url

  scope :for_user, lambda{ |user| where(:destination_url => user.url) }
  scope :from_user, lambda{ |user| where(:destination_url.ne => user.url) }

  def self.instantiate(options ={})
    person = options[:from]
    self.new(:destination_url => options[:to], :callback_url => person.url, :person => person)
  end

  def activate_friend 
    p = Person.where(:id => self.person.id).first
    p.active = true
    p.save
  end

end
