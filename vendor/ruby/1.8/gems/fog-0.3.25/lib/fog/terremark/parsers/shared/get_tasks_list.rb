module Fog
  module Parsers
    module Terremark
      module Shared

        class GetTasksList < Fog::Parsers::Base

          def reset
            @response = { 'Tasks' => [] }
            @task = {}
          end

          def start_element(name, attributes)
            super
            case name
            when 'Owner', 'Result'
              data = {}
              until attributes.empty?
                data[attributes.shift] = attributes.shift
              end
              @task[name] = data
            when 'Task'
              until attributes.empty?
                @task[attributes.shift] = attributes.shift
              end
            when 'TasksList'
              tasks_list = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  tasks_list[attribute.first] = attribute.last
                else
                  tasks_list[attributes.shift] = attributes.shift
                end
              end
              @response['href'] = tasks_list['href']
            end
          end

          def end_element(name)
            if name == 'Task'
              @response['Tasks'] << @task
              @task = {}
            end
          end

        end

      end
    end
  end
end
