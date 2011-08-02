module Fog
  module Parsers
    module Terremark
      module Shared

        class Task < Fog::Parsers::Base

          def reset
            @response = {}
          end

          def start_element(name, attributes)
            super
            case name
            when 'Owner', 'Result', 'Link', 'Error'
              data = {}
              until attributes.empty?
                data[attributes.shift] = attributes.shift
              end
              @response[name] = data
            when 'Task'
              task = {}
              until attributes.empty?
                if attributes.first.is_a?(Array)
                  attribute = attributes.shift
                  task[attribute.first] = attribute.last
                else
                  task[attributes.shift] = attributes.shift
                end
              end
              @response.merge!(task.reject {|key,value| !['endTime', 'href', 'startTime', 'status', 'type'].include?(key)})
            end
          end

        end

      end
    end
  end
end
