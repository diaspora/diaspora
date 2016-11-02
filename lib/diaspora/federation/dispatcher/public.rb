module Diaspora
  module Federation
    class Dispatcher
      class Public < Dispatcher
        private

        def deliver_to_services
          deliver_to_hub if object.instance_of?(StatusMessage)
          super
        end

        def deliver_to_remote(people)
          targets = target_urls(people) + additional_target_urls

          return if targets.empty?

          entity = Entities.build(object)
          Workers::SendPublic.perform_async(sender.id, entity.to_s, targets, salmon_xml(entity))
        end

        def target_urls(people)
          active, inactive = Pod.where(id: people.map(&:pod_id).uniq).partition(&:active?)
          logger.info "ignoring inactive pods: #{inactive.join(', ')}" if inactive.any?
          active.map {|pod| pod.url_to("/receive/public") }
        end

        def additional_target_urls
          return [] unless AppConfig.relay.outbound.send? && object.instance_of?(StatusMessage)
          [AppConfig.relay.outbound.url]
        end

        def salmon_xml(entity)
          DiasporaFederation::Salmon::Slap.generate_xml(
            sender.diaspora_handle,
            sender.encryption_key,
            entity
          )
        end

        def deliver_to_hub
          logger.debug "deliver to pubsubhubbub sender: #{sender.diaspora_handle}"
          Workers::PublishToHub.perform_async(sender.atom_url)
        end
      end
    end
  end
end
