require 'uri'
class OEmbedPresenter
  include PostsHelper
  include ActionView::Helpers::TextHelper

  def initialize(post, opts = {})
    @post = post
    @opts = opts
  end

  def to_json(opts={})
    as_json(opts).to_json
  end

  def as_json(opts={})
    {
      :provider_name => "Diaspora", 
      :provider_hurl => AppConfig[:pod_url],
      :type => 'rich',
      :version => '1.0',
      :title => post_title,
      :author_name => post_author,
      :author_url => post_author_url,
      :width => @opts.fetch(:maxwidth, 516), 
      :height => @opts.fetch(:maxheight, 320),
      :html => iframe_html
    }
  end

  def self.id_from_url(url)
    URI.parse(url).path.gsub(%r{\/posts\/|\/p\/}, '')
  end

  def post_title
    post_page_title(@post)
  end

  def post_author
    @post.author_name
  end

  def post_author_url
   Rails.application.routes.url_helpers.person_url(@post.author, :host => AppConfig[:pod_uri].host)
  end

  def iframe_html
    post_iframe_url(@post.id, :height => @opts[:maxheight], :width => @opts[:maxwidth])
  end
end
