class Retraction
  include ROXML
  include Diaspora::Webhooks
  include Encryptable

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
    return unless verify_signature(@creator_signature, Post.first(:id => post_id).person)
     
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

#ENCRYPTION
    xml_reader :creator_signature
    
    def creator_signature
      @creator_signature ||= sign if person_id == User.owner.id
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
