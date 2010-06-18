class Bookmark < Post
  
  xml_accessor :link
  xml_accessor :title
  
  field :link
  field :title
  
  
  validates_presence_of :link  

  validates_format_of :link, :with =>
    /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

  before_validation :clean_link

  protected

  def clean_link
    if self.link
      self.link = 'http://' + self.link unless self.link.match('http://' || 'https://')
      self.link = self.link + '/' if self.link[-1,1] != '/'
    end
  end
end
