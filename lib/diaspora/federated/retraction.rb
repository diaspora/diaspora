#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Retraction
  include Diaspora::Federated::Base
  include Diaspora::Logging

  attr_reader :subscribers, :data

  def initialize(data, subscribers, target=nil)
    @data = data
    @subscribers = subscribers
    @target = target
  end

  def self.for(target, sender=nil)
    federation_retraction = case target
                            when Diaspora::Relayable
                              Diaspora::Federation::Entities.relayable_retraction(target, sender)
                            when Post
                              Diaspora::Federation::Entities.signed_retraction(target, sender)
                            else
                              Diaspora::Federation::Entities.retraction(target)
                            end

    new(federation_retraction.to_h, target.subscribers.select(&:remote?), target)
  end

  def defer_dispatch(user, include_target_author=true)
    subscribers = dispatch_subscribers(include_target_author)
    sender = dispatch_sender(user)
    Workers::DeferredRetraction.perform_async(sender.id, data, subscribers.map(&:id), service_opts(user))
  end

  def perform
    logger.debug "Performing retraction for #{target.class.base_class}:#{target.guid}"
    target.destroy!
    logger.info "event=retraction status=complete target=#{data[:target_type]}:#{data[:target_guid]}"
  end

  def public?
    # TODO: backward compatibility for pre 0.6 pods, they don't relay public retractions
    data[:target][:public] == "true" && (!data[:target][:parent] || data[:target][:parent][:local] == "true")
  end

  private

  attr_reader :target

  def dispatch_subscribers(include_target_author)
    subscribers << target.author if target.is_a?(Diaspora::Relayable) && include_target_author && target.author.remote?
    subscribers
  end

  # @deprecated This is only needed for pre 0.6 pods
  def dispatch_sender(user)
    target.try(:sender_for_dispatch) || user
  end

  def service_opts(user)
    return {} unless target.is_a?(StatusMessage)

    user.services.each_with_object(service_types: []) do |service, opts|
      service_opts = service.post_opts(target)
      if service_opts
        opts.merge!(service_opts)
        opts[:service_types] << service.class.to_s
      end
    end
  end
end
