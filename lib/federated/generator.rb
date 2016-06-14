module Federated
  class Generator
    include Diaspora::Logging

    def initialize(user, target)
      @user = user
      @target = target
      @dispatcher_opts ||= {}
    end

    def create!(options={})
      relayable = build(options)
      if relayable.save!
        logger.info "user:#{@user.id} dispatching #{relayable.class}:#{relayable.guid}"
        add_root_author(relayable)
        Diaspora::Federation::Dispatcher.defer_dispatch(@user, relayable, @dispatcher_opts)
        relayable
      end
    end

    def add_root_author(relayable)
      return unless relayable.parent.respond_to?(:root) && relayable.parent.root
      # Comment post is a reshare, include original author in subscribers
      root_post = relayable.parent.root
      @dispatcher_opts[:additional_subscribers] ||= []
      @dispatcher_opts[:additional_subscribers] << root_post.author
    end

    def build(options={})
      self.class.federated_class.new(options.merge(relayable_options).merge(author_id: @user.person.id))
    end

    protected

    def relayable_options
      {}
    end
  end
end
