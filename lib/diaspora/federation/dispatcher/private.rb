module Diaspora
  module Federation
    class Dispatcher
      class Private < Dispatcher
        private

        def deliver_to_remote(people)
          return if people.empty?

          entity = Entities.build(object)
          Workers::SendPrivate.perform_async(sender.id, entity.to_s, targets(people, salmon_slap(entity)))
        end

        def targets(people, salmon_slap)
          people.map {|person| [person.receive_url, salmon_slap.generate_xml(person.public_key)] }.to_h
        end

        def salmon_slap(entity)
          DiasporaFederation::Salmon::EncryptedSlap.prepare(
            sender.diaspora_handle,
            sender.encryption_key,
            entity
          )
        end
      end
    end
  end
end
