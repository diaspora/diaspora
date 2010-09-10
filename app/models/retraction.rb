class Retraction
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :post_id
  xml_accessor :person_id
  xml_accessor :type

  attr_accessor :post_id
  attr_accessor :person_id
  attr_accessor :type


  def self.for(object)
    retraction = self.new
    if object.is_a? User
      retraction.post_id = object.person.id
      retraction.type = object.person.class.to_s
    else
      retraction.post_id = object.id
      retraction.type = object.class.to_s
    end
    retraction.person_id = person_id_from(object)
    retraction
  end

  def perform receiving_user_id
    Rails.logger.debug "Performing retraction for #{post_id}"
    begin
      Rails.logger.debug("Retracting #{self.type} id: #{self.post_id}")
      target = self.type.constantize.first(:id => self.post_id)
      target.unsocket_from_uid receiving_user_id if target.respond_to? :unsocket_from_uid
      target.destroy
    rescue NameError
      Rails.logger.info("Retraction for unknown type recieved.")
    end
  end

  def self.person_id_from(object)
    object.is_a?(Person) ? object.id : object.person.id
  end
  
  def person
    Person.find_by_id(self.person_id)
  end

end
