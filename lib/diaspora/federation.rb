module Diaspora
  module Federation
    # @deprecated
    def self.xml(entity)
      DiasporaFederation::Salmon::XmlPayload.pack(entity)
    end
  end
end

require "diaspora/federation/entities"
