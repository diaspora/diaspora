module Api
  module V0
    class PersonResource < JSONAPI::Resource
      attributes :guid, :first_name, :last_name, :image_url, :tag_string, :bio, :location, :gender,
                 :formatted_birthday, :tags, :diaspora_handle, :url, :created_at, :updated_at
      has_many :posts

      def self.find_by_key(key, _options)
        person = if diaspora_id?(key)
                   Person.where(diaspora_handle: key.downcase).first
                 else
                   Person.find_by(guid: key)
                 end
        raise JSONAPI::Exceptions::RecordNotFound.new(key) if person.nil?
        resource_for_model(person).new(person, context)
      end

      def self.diaspora_id?(query)
        !query.try(:match, /^(\w)*@([a-zA-Z0-9]|[-]|[.]|[:])*$/).nil?
      end
    end
  end
end
