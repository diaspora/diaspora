module Fog
  class Vcloud
    module Terremark
      class Ecloud
        class InternetService < Fog::Vcloud::Model

          identity :href, :aliases => :Href

          ignore_attributes :xmlns, :xmlns_i

          attribute :name, :aliases => :Name
          attribute :id, :aliases => :Id
          attribute :protocol, :aliases => :Protocol
          attribute :port, :aliases => :Port
          attribute :enabled, :aliases => :Enabled
          attribute :description, :aliases => :Description
          attribute :public_ip, :aliases => :PublicIpAddress
          attribute :timeout, :aliases => :Timeout
          attribute :redirect_url, :aliases => :RedirectURL
          attribute :monitor, :aliases => :Monitor

          def delete
            requires :href

            connection.delete_internet_service( href )
          end

          def save
            if new_record?
              result = connection.add_internet_service( collection.href, _compose_service_data )
              merge_attributes(result.body)
            else
              connection.configure_internet_service( href, _compose_service_data, _compose_ip_data )
            end
          end

          def monitor=(new_monitor = {})
            if new_monitor.nil? || new_monitor.empty?
              @monitor = nil
            elsif new_monitor.is_a?(Hash)
              @monitor = {}
              @monitor[:type] = new_monitor[:MonitorType] || new_monitor[:type]
              @monitor[:url_send_string] = new_monitor[:UrlSendString] || new_monitor[:url_send_string]
              @monitor[:http_headers] = new_monitor[:HttpHeader] || new_monitor[:http_headers]
              @monitor[:http_headers] = @monitor[:http_headers].split("\n") unless @monitor[:http_headers].is_a?(Array)
              @monitor[:receive_string] = new_monitor[:ReceiveString] || new_monitor[:receive_string]
              @monitor[:interval] = new_monitor[:Interval] || new_monitor[:interval]
              @monitor[:response_timeout] = new_monitor[:ResponseTimeOut] || new_monitor[:response_timeout]
              @monitor[:downtime] = new_monitor[:DownTime] || new_monitor[:downtime]
              @monitor[:retries] = new_monitor[:Retries] || new_monitor[:retries]
              @monitor[:is_enabled] = new_monitor[:IsEnabled] || new_monitor[:is_enabled]
            else
              raise RuntimeError.new("monitor needs to either be nil or a Hash")
            end
          end

          def nodes
            @nodes ||= Fog::Vcloud::Terremark::Ecloud::Nodes.new( :connection => connection, :href => href + "/nodeServices" )
          end

          private

          def _compose_service_data
            #For some reason inject didn't work
            service_data = {}
            self.class.attributes.select{ |attribute| !send(attribute).nil? }.each { |attribute| service_data[attribute] = send(attribute) }
            service_data
          end

          def _compose_ip_data
            if public_ip.nil?
              {}
            else
              { :id => public_ip[:Id], :href => public_ip[:Href], :name => public_ip[:Name] }
            end
          end

        end
      end
    end
  end
end


