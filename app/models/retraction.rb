class Retraction
  include ROXML
  include Diaspora::Webhooks

  def self.for(post)
    result = self.new
    result.post_id = post.id
    result.person_id = post.person.id
    result
  end

  xml_accessor :post_id
  xml_accessor :person_id

  attr_accessor :post_id
  attr_accessor :person_id
  
end
