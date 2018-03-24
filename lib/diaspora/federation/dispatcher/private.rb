# frozen_string_literal: true

module Diaspora
  module Federation
    class Dispatcher
      class Private < Dispatcher
        private

        def deliver_to_remote(people)
          return if people.empty?

          Workers::SendPrivate.perform_async(sender.id, entity.to_s, targets(people))
        end

        def targets(people)
          active, inactive = people.partition {|person| person.pod.active? }
          logger.info "ignoring inactive pods: #{inactive.map(&:diaspora_handle).join(', ')}" if inactive.any?
          active.map {|person| [person.receive_url, encrypted_magic_envelope(person)] }.to_h
        end

        def encrypted_magic_envelope(person)
          DiasporaFederation::Salmon::EncryptedMagicEnvelope.encrypt(magic_envelope, person.public_key)
        end
      end
    end
  end
end
