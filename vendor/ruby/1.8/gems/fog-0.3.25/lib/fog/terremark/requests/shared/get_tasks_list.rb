module Fog
  module Terremark
    module Shared
      module Real

        # Get list of tasks
        #
        # ==== Parameters
        # * tasks_list_id<~Integer> - Id of tasks lists to view
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'CatalogItems'<~Array>
        #       * 'href'<~String> - linke to item
        #       * 'name'<~String> - name of item
        #       * 'type'<~String> - type of item
        #     * 'description'<~String> - Description of catalog
        #     * 'name'<~String> - Name of catalog
        def get_tasks_list(tasks_list_id)
          request(
            :expects  => 200,
            :method   => 'GET',
            :parser   => Fog::Parsers::Terremark::Shared::GetTasksList.new,
            :path     => "tasksList/#{tasks_list_id}"
          )
        end

      end

      module Mock

        def get_tasks_list(tasks_list_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
