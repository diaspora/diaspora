module Export
  class OthersDataSerializer < ActiveModel::Serializer
    # Relayables of other people in the archive: comments, likes, participations, poll participations where author is
    # the archive owner
    has_many :relayables, each_serializer: FederationEntitySerializer

    # Parent posts of user's own relayables. We have to save metadata to use
    # it in case when posts temporary unavailable on the target pod.
    has_many :posts, each_serializer: FederationEntitySerializer

    # Authors of posts where we participated and authors are not in contacts
    has_many :non_contact_authors, each_serializer: PersonMetadataSerializer

    private

    def relayables
      %i[comments likes poll_participations].map {|relayable|
        others_relayables.send(relayable)
      }.sum
    end

    def others_relayables
      @others_relayables ||= Diaspora::Exporter::OthersRelayables.new(object.person_id)
    end

    def posts
      @posts ||= Diaspora::Exporter::PostsWithActivity.new(object).query
    end

    def non_contact_authors
      Diaspora::Exporter::NonContactAuthors.new(posts, object).query
    end
  end
end
