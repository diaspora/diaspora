# frozen_string_literal: true

module Diaspora
  module Federated
    module Fetchable
      extend ActiveSupport::Concern

      module ClassMethods
        def find_or_fetch_by(diaspora_id, guid)
          instance = find_by(guid: guid)
          return instance if instance.present?

          DiasporaFederation::Federation::Fetcher.fetch_public(diaspora_id, to_s, guid)
          find_by(guid: guid)
        rescue DiasporaFederation::Federation::Fetcher::NotFetchable
          nil
        end
      end
    end
  end
end
