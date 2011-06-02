class Services::Tumblr < Service
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
    begin
      resp = access.post('http://tumblr.com/api/write', {:type => 'regular', :title => self.public_message(post, url), :generator => 'diaspora'})
      resp
    rescue
      nil
    end
  end

  def public_message(post, url)
    super(post, MAX_CHARACTERS,  url)
  end
end

