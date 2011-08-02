module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_task
        end

        class Mock
          def get_task(task__uri)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end
