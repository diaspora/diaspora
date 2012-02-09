class Participation < Federated::Relayable
  class Generator < Federated::Generator
    def self.federated_class
     Participation
    end

    def relayable_options
      {:target => @target}
    end
  end
end