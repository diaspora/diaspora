class TemplatePicker
  attr_accessor :post

  TEMPLATES = %w{ status_with_photo_backdrop
                  note
                  rich_media
                  multi_photo
                  photo_backdrop
                  activity_streams_photo
                  status
                }

  def initialize(post)
    self.post = post
  end

  def template_name
    TEMPLATES.each do |template|
      return template.gsub("_", '-') if self.send("#{template}?".to_sym)
    end

    'status' #default
  end

  def status_with_photo_backdrop?
    status? && photo_backdrop?
  end

  def note?
    self.status? && post.text.length > 300
  end

  def rich_media?
    post.o_embed_cache.present?
  end

  def multi_photo?
    post.photos.size > 1
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
end