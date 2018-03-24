# frozen_string_literal: true

OpenGraphReader.configure do |config|
  config.synthesize_title      = true
  config.synthesize_url        = true
  config.synthesize_full_url   = true
  config.synthesize_image_url  = true
  config.guess_datetime_format = true
end

og_video_urls = []
og_providers = YAML.load_file(Rails.root.join("config", "open_graph_providers.yml"))
og_providers.each do |_, provider|
  provider["video_urls"].each do |video_url|
    # taken from https://github.com/ruby-oembed/ruby-oembed/blob/fe2b63c/lib/oembed/provider.rb#L68
    _, scheme, domain, path = *video_url.match(%r{([^:]*)://?([^/?]*)(.*)})
    domain = Regexp.escape(domain).gsub("\\*", "(.*?)").gsub("(.*?)\\.", "([^\\.]+\\.)?")
    path = Regexp.escape(path).gsub("\\*", "(.*?)")
    url = Regexp.new("^#{Regexp.escape(scheme)}://#{domain}#{path}")
    og_video_urls << url
  end if provider["video_urls"]
end

SECURE_OPENGRAPH_VIDEO_URLS = og_video_urls
