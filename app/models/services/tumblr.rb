class Services::Tumblr < Service
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper

  MAX_CHARACTERS = 1000

  def provider
    "tumblr"
  end

  def consumer_key
    SERVICES['tumblr']['consumer_key']
  end

  def consumer_secret
    SERVICES['tumblr']['consumer_secret']
  end

  def post(post, url='')

    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => 'http://tumblr.com')
    access = OAuth::AccessToken.new(consumer, self.access_token, self.access_secret)
    body = build_tumblr_post(post, url)
    begin
      resp = access.post('http://tumblr.com/api/write', body)
      resp
    rescue => e
      nil
    end
  end

  def build_tumblr_post(post, url)
    {:generator => 'diaspora', :type => 'regular', :body => tumblr_template(post, url)}
  end

  def tumblr_template(post, url)
    html = ''
    post.photos.each do |photo|
      html += "<img src='#{photo.url(:scaled_full)}'/><br>"
    end
    html += auto_link(post.text, :link => :urls)
  end
end

