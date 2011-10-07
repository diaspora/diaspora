#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublisherHelper
  def public_value
    params[:controller] == "tags" || params[:controller] == "posts"
  end

  def remote?
    params[:controller] != "tags"
  end

  def public_helper_text
    (public_value)? t('javascripts.publisher.public'): t('javascripts.publisher.limited')
  end
end
