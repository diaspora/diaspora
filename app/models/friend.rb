class Friend < Person

  xml_accessor :url

  field :url

  validates_presence_of :url
  validates_format_of :url, :with =>
     /^(https?):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*(\.[a-z]{2,5})?(:[0-9]{1,5})?(\/.*)?$/ix
    
  #validate {self.url ! = User.first.url}

  before_validation :clean_url

  protected

  def clean_url
    if self.url
      self.url = 'http://' + self.url unless self.url.match('http://' || 'https://')
      self.url = self.url + '/' if self.url[-1,1] != '/'
    end
  end
end
