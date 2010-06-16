class Post 

  # XML accessors must always preceed mongo field tags

  include Mongoid::Document
  include Mongoid::Timestamps
  include ROXML

  xml_accessor :owner
  xml_accessor :snippet
  xml_accessor :source

  field :owner
  field :source
  field :snippet


  before_create :set_defaults

  protected

  def set_defaults
    user_email = User.first.email
    self.owner ||= user_email
    self.source ||= user_email
    self.snippet ||= user_email
  end
end


