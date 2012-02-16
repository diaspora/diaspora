require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'template_picker')

class PostPresenter
  attr_accessor :post

  def initialize(post)
    self.post = post
  end

  def to_json(options = {})
    {
      :post => self.post.as_api_response(:backbone),
      :templateName => TemplatePicker.new(self.post).template_name
    }
  end
end