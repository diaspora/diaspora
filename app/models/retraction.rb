class Retraction
  include ROXML
  include Diaspora::Webhooks

  def self.for(object)
    retraction = self.new
    retraction.post_id= object.id
    retraction.person_id = person_id_from(object)
    retraction.type = object.class.to_s
    retraction
  end

  xml_accessor :post_id
  xml_accessor :person_id
  xml_accessor :type

  attr_accessor :post_id
  attr_accessor :person_id
  attr_accessor :type

  def perform
    begin
      self.type.constantize.destroy(self.post_id)
    rescue NameError
      Rails.logger.info("Retraction for unknown type recieved.")
    end
  end

  def self.person_id_from(object)
    if object.is_a? Person
      object.id
    else
      object.person.id
    end
  end

end
