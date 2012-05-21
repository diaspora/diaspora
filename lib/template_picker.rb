class TemplatePicker
  attr_accessor :post

  TEMPLATES = %w{ status_with_photo_backdrop
                  note
                  photo_backdrop
                  activity_streams_photo
                  status
                }

  def initialize(post)
    self.post = post
  end

  def template_name
    TEMPLATES.each do |template|
      return TemplatePicker.jsonify_name(template) if self.send("#{template}?".to_sym)
    end

    'status' #default
  end

  def status_with_photo_backdrop?
    status? && photo_backdrop?
  end

  def note?
    self.status? && post.text(:plain_text => true).length > 200
  end

  def photo_backdrop?
    post.photos.size == 1 
  end

  def activity_streams_photo?
    post.type == "ActivityStreams::Photo"
  end

  def status?
    post.text?
  end

  def self.jsonified_templates
    TEMPLATES.map{|x| jsonify_name(x)}
  end

  def self.jsonify_name(name)
    name.gsub('_', '-')
  end
end