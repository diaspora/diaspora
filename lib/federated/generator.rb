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
        Postzord::Dispatcher.defer_build_and_post(@user, relayable, @dispatcher_opts)
        relayable
      end
    end

    def build(options={})
      options.merge!(relayable_options)
      relayable = self.class.federated_class.new(options.merge(:author_id => @user.person.id))
      relayable.set_guid
      relayable.initialize_signatures
      relayable
    end

    protected

    def relayable_options
      {}
    end
  end
end
