module Diaspora
  module Federation
    class Dispatcher
      class Public < Dispatcher
        def deliver_to_services
          # TODO: pubsubhubbub, relay
          super
        end

        def deliver_to_remote(people)
          # TODO
        end
      end
    end
  end
end
