# frozen_string_literal: true

class OEmbedPresenter
  include PostsHelper

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
      :provider_url => AppConfig.pod_uri.to_s,
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
    AppConfig.url_to(Rails.application.routes.url_helpers.person_path(@post.author))
  end

  def iframe_html
    post_iframe_url(@post.id, :height => @opts[:maxheight], :width => @opts[:maxwidth])
  end
end
