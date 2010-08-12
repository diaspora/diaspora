class Retraction
  include ROXML
  include Diaspora::Webhooks
  include Encryptable

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
    retraction.send(:sign_if_mine)
    retraction
  end

  xml_accessor :post_id
  xml_accessor :person_id
  xml_accessor :type

  attr_accessor :post_id
  attr_accessor :person_id
  attr_accessor :type

  def perform receiving_user_id
    Rails.logger.debug "Performing retraction for #{post_id}"
    begin
      return unless signature_valid? 
      Rails.logger.debug("Retracting #{self.type} id: #{self.post_id}")
      target = self.type.constantize.first(self.post_id)
      target.unsocket_from_uid receiving_user_id if target.respond_to? :unsocket_from_uid
      target.destroy
    rescue NameError
      Rails.logger.info("Retraction for unknown type recieved.")
    end
  end

  def signature_valid?
    target = self.type.constantize.first(:id => self.post_id)
    if target.is_a? Person
      verify_signature(@creator_signature, self.type.constantize.first(:id => self.post_id))
    else 
      verify_signature(@creator_signature, self.type.constantize.first(:id => self.post_id).person)
    end
  end

  def self.person_id_from(object)
    if object.is_a? Person
      object.id
    else
      object.person.id
    end
  end
  
  def person
    Person.first(:id => self.person_id)
  end

#ENCRYPTION
    xml_reader :creator_signature
    
    def creator_signature
      object =  self.type.constantize.first(:id => post_id)

      if object.class == Person && person_id == object.id
        @creator_signature || sign_with_key(object.key)
      elsif person_id == object.person.id
        @creator_signature || sign_if_mine 
      end
    end

    def creator_signature= input
      @creator_signature = input
    end

    def signable_accessors
      accessors = self.class.roxml_attrs.collect{|definition| 
        definition.accessor}
      accessors.delete 'person'
      accessors.delete 'creator_signature'
      accessors
    end

    def signable_string
      signable_accessors.collect{|accessor| 
        (self.send accessor.to_sym).to_s}.join ';'
    end
  
end
