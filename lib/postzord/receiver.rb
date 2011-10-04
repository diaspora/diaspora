#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class Postzord::Receiver
  require File.join(Rails.root, 'lib/postzord/receiver/private')
  require File.join(Rails.root, 'lib/postzord/receiver/public')

  def perform!
    receive!
    update_cache! if cache?
  end

  # @return [Boolean]
  def cache?
    self.respond_to?(:update_cache!) && RedisCache.configured? &&
      @object.respond_to?(:triggers_caching?) && @object.triggers_caching? &&
      @object.respond_to?(:type) && RedisCache.acceptable_types.include?(@object.type)
  end
end

