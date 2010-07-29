class Profile
  include MongoMapper::EmbeddedDocument
  include ROXML

  xml_accessor :first_name
  xml_accessor :last_name
  xml_accessor :image_url

  key :first_name, String
  key :last_name, String
  key :image_url, String

  validates_presence_of :first_name, :last_name

  # before_save :expand_profile_photo_path
  # 
  # 
  # def expand_profile_photo_path
  #   unless image_url.nil? || self.image_url.include?(parent_document.url)
  #     self.image_url = self._parent_document.url + self.image_url
  #   end
  # end
  
end
