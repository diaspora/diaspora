#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PostsHelper
  def post_iframe_url(post_id, opts={})
    opts[:width] ||= 516
    opts[:height] ||= 315
    "<iframe src='#{AppConfig.url_to(Rails.application.routes.url_helpers.post_path(post_id))}' " \
      "width='#{opts[:width]}px' height='#{opts[:height]}px' frameBorder='0'></iframe>".html_safe
  end
end
