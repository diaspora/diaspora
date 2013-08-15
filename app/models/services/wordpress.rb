class Services::Wordpress < Service
  include ActionView::Helpers::TextHelper
  include MarkdownifyHelper
  
  MAX_CHARACTERS = 1000
  
  attr_accessor :username, :password, :host, :path
  
  # uid = blog_id
  
  def provider
    "wordpress"
  end
  
  def post(post, url='')
    res = Faraday.new(:url => "https://public-api.wordpress.com").post do |req|
      req.url "/rest/v1/sites/#{self.uid}/posts/new"
      req.body = post_body(post).to_json
      req.headers['Authorization'] = "Bearer #{self.access_token}"
      req.headers['Content-Type'] = 'application/json'
    end
    JSON.parse res.env[:body]
  end
  
  def post_body(post, url='')
    post_text = markdownify(post.text)
    post_title = truncate(strip_markdown(post.text(:plain_text => true)), :length => 40, :separator => ' ')
    
    {:title => post_title, :content => post_text.html_safe}
  end
  
end
