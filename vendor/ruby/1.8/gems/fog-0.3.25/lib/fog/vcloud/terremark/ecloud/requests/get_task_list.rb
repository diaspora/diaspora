module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Real
          basic_request :get_task_list
        end

        class Mock
          def get_task_list(task_list_uri)
            Fog::Mock.not_implemented
          end
        end
      end
    end
  end
end

