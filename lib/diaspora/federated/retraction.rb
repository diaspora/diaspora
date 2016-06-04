#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
class Retraction
  include Diaspora::Federated::Base

  xml_accessor :post_guid
  xml_accessor :diaspora_handle
  xml_accessor :type

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

  def defer_dispatch(user)
    Workers::DeferredRetraction.perform_async(user.id, data, subscribers.map(&:id)) unless subscribers.empty?
  end

  def perform
    logger.debug "Performing retraction for #{target.class.base_class}:#{target.guid}"
    target.destroy!
    logger.info "event=retraction status=complete target=#{data[:target_type]}:#{data[:target_guid]}"
  end

  def public?
    data[:target][:public]
  end

  private

  attr_reader :target
end
