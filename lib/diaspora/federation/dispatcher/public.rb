module Diaspora
  module Federation
    class Dispatcher
      class Public < Dispatcher
        def deliver_to_services
          # TODO: pubsubhubbub, relay
          super
        end

        def deliver_to_remote(people)
          entity = Entities.build(object)
          Workers::SendPublic.perform_async(sender.id, entity.to_s, target_urls(people), salmon_xml(entity))
        end

        private

        def target_urls(people)
          Pod.where(id: people.map(&:pod_id).uniq).map {|pod| pod.url_to("/receive/public") }
        end

        def salmon_xml(entity)
          DiasporaFederation::Salmon::Slap.generate_xml(
            sender.diaspora_handle,
            sender.encryption_key,
            entity
          )
        end
      end
    end
  end
end
