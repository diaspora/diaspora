#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module ApplicationHelper
  def pod_name
    AppConfig.settings.pod_name
  end

  def pod_version
    AppConfig.version.number
  end

  def changelog_url
    url = "https://github.com/diaspora/diaspora/blob/master/Changelog.md"
    url.sub!('/master/', "/#{AppConfig.git_revision}/") if AppConfig.git_revision.present?
    url
  end

  def source_url
    AppConfig.settings.source_url.presence || "#{root_path.chomp('/')}/source.tar.gz"
  end

  def timeago(time, options={})
    timeago_tag(time, options.merge(:class => 'timeago', :title => time.iso8601, :force => true)) if time
  end

  def bookmarklet_code(height=400, width=620)
    "javascript:" +
      BookmarkletRenderer.body +
      "bookmarklet('#{bookmarklet_url}', #{width}, #{height});"
  end

  def contacts_link
    if current_user.contacts.size > 0
      contacts_path
    else
      community_spotlight_path
    end
  end

  def all_services_connected?
    current_user.services.size == AppConfig.configured_services.size
  end

  def popover_with_close_html(without_close_html)
    without_close_html + link_to('&times;'.html_safe, "#", :class => 'close')
  end

  # Require jQuery from CDN if possible, falling back to vendored copy, and require
  # vendored jquery_ujs
  def jquery_include_tag
    buf = []
    if AppConfig.privacy.jquery_cdn?
      version = Jquery::Rails::JQUERY_2_VERSION
      buf << [ javascript_include_tag("//code.jquery.com/jquery-#{version}.min.js") ]
      buf << [javascript_tag("!window.jQuery && document.write(unescape('#{j javascript_include_tag('jquery2')}'));")]
    else
      buf << [javascript_include_tag("jquery2")]
    end
    buf << [ javascript_include_tag('jquery_ujs') ]
    buf << [ javascript_tag("jQuery.ajaxSetup({'cache': false});") ]
    buf << [ javascript_tag("$.fx.off = true;") ] if Rails.env.test?
    buf.join("\n").html_safe
  end

  # TODO: Revisit after Rails decision about https://github.com/rails/rails/pull/19378
  #
  # Replicates rails's [current_page?] method, so it respects the format appended to the url
  # We should remove this method when [rails] update it.
  #
  # Let's say we're in the <tt>http://www.diaspora-pod-example.com/aspects.mobile</tt>
  # diaspora_current_page?(:aspects)
  # => true
  #
  def diaspora_current_page?(options)
    unless request
      raise "You cannot use helpers that need to determine the current " \
             "page unless your view context provides a Request object " \
             "in a #request method"
    end

    return false unless request.get? || request.head?

    url_string = URI.parser.unescape(url_for(options)).force_encoding(Encoding::BINARY)

    # We ignore any extra parameters in the request_uri if the
    # submitted url doesn't have any either. This lets the function
    # work with things like ?order=asc
    request_uri = url_string.index("?") ? request.fullpath : request.path
    request_uri = URI.parser.unescape(request_uri).force_encoding(Encoding::BINARY)

    unless options.is_a?(Hash) && options[:format]
      regexp = Regexp.new(request_uri.index("?") ? /[.].*(?=\?)/ : /[.].*$/)
      request_uri.sub!(regexp, "")
    end

    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
    else
      url_string == request_uri
    end
  end
end