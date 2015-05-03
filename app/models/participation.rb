class Participation < Federated::Relayable
  class Generator < Federated::Generator
    def self.federated_class
     Participation
    end

    def relayable_options
      {:target => @target}
    end
  end

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :author
    t.add :created_at
  end
end
