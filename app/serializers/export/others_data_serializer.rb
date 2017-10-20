# frozen_string_literal: true

module Export
  class OthersDataSerializer < ActiveModel::Serializer
    # Relayables of other people in the archive: comments, likes, participations, poll participations where author is
    # the archive owner
    has_many :relayables, serializer: FlatMapArraySerializer, each_serializer: FederationEntitySerializer

    def initialize(user_id)
      @user_id = user_id
      super(object)
    end

    private

    def object
      User.find(@user_id)
    end

    def relayables
      %i[comments likes poll_participations].map {|relayable|
        others_relayables.send(relayable).find_each(batch_size: 20)
      }
    end

    def others_relayables
      @others_relayables ||= Diaspora::Exporter::OthersRelayables.new(object.person_id)
    end

    # Avoid calling pointless #embedded_in_root_associations method
    def serializable_data
      {}
    end
  end
end
