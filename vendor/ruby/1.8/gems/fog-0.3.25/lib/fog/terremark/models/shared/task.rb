require 'fog/core/model'

module Fog
  module Terremark
    module Shared

      class Task < Fog::Model

        identity :id

        attribute :end_time,    :aliases => 'endTime'
        attribute :owner,       :aliases => 'Owner'
        attribute :result,      :aliases => 'Result'
        attribute :start_time,  :aliases => 'startTime'
        attribute :status
        attribute :link,        :aliases => 'Link'
        attribute :error,       :aliases => 'Error'

        def initialize(attributes = {})
          new_owner  = attributes.delete('Owner')
          new_result = attributes.delete('Result')
          new_error = attributes.delete('Error')
          new_cancel_link = attributes.delete('Link')

          super
          self.owner = connection.parse(new_owner)
          if new_result
            self.result = connection.parse(new_result)
          end
          self.error = connection.parse(new_error) if new_error
          @cancel_link = connection.parse(new_cancel_link) if new_cancel_link
        end

        def ready?
          @status == 'success'
        end

        private

        def href=(new_href)
          @id = new_href.split('/').last.to_i
        end

        def type=(new_type); end

      end

    end
  end
end
