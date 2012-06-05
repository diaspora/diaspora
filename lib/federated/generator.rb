module Federated
  class Generator
    def initialize(user, target)
      @user = user
      @target = target
    end

    def create!(options={})
      relayable = build(options)
      if relayable.save!
        FEDERATION_LOGGER.info("user:#{@user.id} dispatching #{relayable.class}:#{relayable.guid}")
        Postzord::Dispatcher.defer_build_and_post(@user, relayable)
        relayable
      else
        false
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