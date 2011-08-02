require 'fog/vcloud/terremark/ecloud/models/task'

module Fog
  class Vcloud
    module Terremark
      class Ecloud

        class Tasks < Fog::Vcloud::Collection

          model Fog::Vcloud::Terremark::Ecloud::Task

          attribute :href, :aliases => :Href

          def all
            check_href!
            if data = connection.get_task_list(href).body[:Task]
              load(data)
            end
          end

          def get(uri)
            if data = connection.get_task(uri)
              new(data.body)
            end
          rescue Fog::Errors::NotFound
            nil
          end

        end
      end
    end
  end
end
