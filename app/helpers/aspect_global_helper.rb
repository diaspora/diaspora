# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspect_options_for_select(aspects)
    options = {}
    aspects.each do |aspect|
      options[aspect.to_s] = aspect.id
    end
    options
  end

  def publisher_aspects_for(stream)
    if stream
      aspects = stream.aspects
      aspect = stream.aspect
      aspect_ids = stream.aspect_ids
    elsif current_user
      aspects = current_user.post_default_aspects
      aspect = aspects.first
      aspect_ids = current_user.aspect_ids
    else
      return {}
    end
    {selected_aspects: aspects, aspect: aspect, aspect_ids: aspect_ids}
  end
end
