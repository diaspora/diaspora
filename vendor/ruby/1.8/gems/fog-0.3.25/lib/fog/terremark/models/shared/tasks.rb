require 'fog/core/collection'
require 'fog/terremark/models/shared/server'

module Fog
  module Terremark
    module Shared

      module Mock
        def tasks
          Fog::Terremark::Shared::Tasks.new(:connection => self)
        end
      end

      module Real
        def tasks
          Fog::Terremark::Shared::Tasks.new(:connection => self)
        end
      end

      class Tasks < Fog::Collection

        model Fog::Terremark::Shared::Task

        def all
          data = connection.get_tasks_list(task_list_id).body['Tasks']
          load(data)
        end

        def get(task_id)
          if task_id && task = connection.get_task(task_id).body
            new(task)
          elsif !task_id
            nil
          end
        rescue Excon::Errors::Forbidden
          nil
        end

        def task_list_id
          @task_list_id ||=
            if connection.default_organization_id && organization = connection.get_organization(connection.default_organization_id).body
              organization['Links'].detect {|link| link['type'] == 'application/vnd.vmware.vcloud.tasksList+xml'}['href'].split('/').last.to_i
            else
              nil
            end
        end

        private

        def task_list_id=(new_task_list_id)
          @task_list_id = new_task_list_id
        end

      end

    end
  end
end
