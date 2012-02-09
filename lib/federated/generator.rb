module Federated
  class Generator
    def initialize(person, target)
      @person = person
      @target = target
    end

    def build(options={})
      options.merge!(relayable_options)
      relayable = self.class.federated_class.new(options.merge(:author_id => @person.id))
      relayable.set_guid
      relayable.initialize_signatures
      relayable
    end

    def create!(options={})
      relayable = build(options)
      if relayable.save
        Postzord::Dispatcher.defer_build_and_post(@person, relayable)
        relayable
      else
        false
      end
    end

    protected

    def relayable_options
      {}
    end
  end
end