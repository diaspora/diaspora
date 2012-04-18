class OEmbedPresenter
  include PostsHelper

  def initialize(post, opts = {})
    @post = post
    @opts = opts
  end

  def to_json(opts={})
    as_json(opts).to_json
  end

  def as_json(opts)
    {
      :provider_name => "Diaspora", 
      :provider_url => AppConfig[:pod_url],
      :version => '1.0',
      :title => post_title,
      :author_name => post_author,
      :author_url => post_author_url,
      :width => @opts.fetch(:height, 516), 
      :height => @opts.fetch(:width, 320),
      :html => iframe_html
    }
  end

  private

  def post_title
    @post.text
  end

  def post_author
    @post.author.name
  end

  def post_author_url
   Rails.application.routes.url_helpers.person_url(@post.author)
  end

  def iframe_html
    post_iframe_url(@post.id)
  end
end